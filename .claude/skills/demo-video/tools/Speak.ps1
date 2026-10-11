<#
.SYNOPSIS
  Synthesises narration for one scene and writes the audio plus word timings.
  Voice "aria" uses Microsoft's Edge read-aloud neural voice (en-US-AriaNeural) through a
  built-in .NET WebSocket client; voice "builtin" uses the voices installed in Windows.
  No external libraries.
.OUTPUTS
  <OutBase>.mp3 (aria) or <OutBase>.wav (builtin), and <OutBase>.words.json:
  { "voice": ..., "audio": path, "duration": seconds, "words": [ { "text", "start", "end" } ] }
.EXAMPLE
  .\Speak.ps1 -Text "This dashboard shows every open invoice." -OutBase demo\audio\s01 -Voice aria
#>
param(
    [Parameter(Mandatory)][string]$Text,
    [Parameter(Mandatory)][string]$OutBase,
    [ValidateSet('aria', 'builtin')][string]$Voice = 'aria',
    [string]$AriaVoiceName = 'en-US-AriaNeural',
    [string]$Rate = '+0%',
    # The Edge read-aloud service honours prosody pitch, rate and volume only. Tested 2026-10: any other SSML
    # (break, emphasis, sub, mstts:express-as styles) makes it return no audio, so pauses are made by
    # synthesising phrases separately and pronunciation by respelling (project voice.lexicon).
    [string]$Pitch = '+0Hz',     # e.g. '+5Hz', '-3Hz'
    [string]$Volume = '+0%',
    [string]$BuiltinVoiceName = ''
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'DemoKit.psm1') -Force
New-Item -ItemType Directory -Force ([IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($OutBase))) | Out-Null

function ConvertTo-XmlText([string]$s) { [Security.SecurityElement]::Escape($s) }

# Minimal RFC 6455 WebSocket client on TcpClient + SslStream. .NET Framework's ClientWebSocket
# cannot send a User-Agent header, and the read-aloud service rejects requests without one (403).
function Open-RawWebSocket([string]$HostName, [string]$PathAndQuery, [hashtable]$Headers) {
    $tcp = New-Object Net.Sockets.TcpClient($HostName, 443)
    $ssl = New-Object Net.Security.SslStream($tcp.GetStream(), $false)
    $ssl.AuthenticateAsClient($HostName, $null, [Security.Authentication.SslProtocols]::Tls12, $true)
    $key = [Convert]::ToBase64String((1..16 | ForEach-Object { [byte](Get-Random -Maximum 256) }))
    $req = "GET $PathAndQuery HTTP/1.1`r`nHost: $HostName`r`nUpgrade: websocket`r`nConnection: Upgrade`r`nSec-WebSocket-Key: $key`r`nSec-WebSocket-Version: 13`r`n"
    foreach ($k in $Headers.Keys) { $req += "${k}: $($Headers[$k])`r`n" }
    $req += "`r`n"
    $b = [Text.Encoding]::ASCII.GetBytes($req); $ssl.Write($b, 0, $b.Length); $ssl.Flush()
    $resp = New-Object Text.StringBuilder
    while (-not $resp.ToString().EndsWith("`r`n`r`n")) {
        $c = $ssl.ReadByte(); if ($c -lt 0) { throw 'Connection closed during WebSocket handshake.' }
        [void]$resp.Append([char]$c)
    }
    $status = $resp.ToString().Split("`r`n")[0]
    if ($status -notmatch ' 101 ') { $tcp.Close(); throw "WebSocket handshake rejected: $status" }
    @{ Tcp = $tcp; Stream = $ssl }
}
function Read-Exact($Stream, [int]$Count) {
    $buf = New-Object byte[] $Count; $off = 0
    while ($off -lt $Count) { $n = $Stream.Read($buf, $off, $Count - $off); if ($n -le 0) { throw 'WebSocket closed unexpectedly.' }; $off += $n }
    , $buf
}
function Send-WsFrame($Ws, [byte[]]$Payload, [int]$Opcode = 1) {
    $len = $Payload.Length
    $head = New-Object Collections.Generic.List[byte]
    $head.Add([byte](0x80 -bor $Opcode))
    if ($len -lt 126) { $head.Add([byte](0x80 -bor $len)) }
    elseif ($len -lt 65536) { $head.Add(0xFE); $head.Add([byte]($len -shr 8)); $head.Add([byte]($len -band 0xFF)) }
    else { $head.Add(0xFF); for ($i = 7; $i -ge 0; $i--) { $head.Add([byte](([long]$len -shr (8 * $i)) -band 0xFF)) } }
    $mask = 1..4 | ForEach-Object { [byte](Get-Random -Maximum 256) }
    foreach ($m in $mask) { $head.Add($m) }
    $masked = New-Object byte[] $len
    for ($i = 0; $i -lt $len; $i++) { $masked[$i] = $Payload[$i] -bxor $mask[$i % 4] }
    $h = $head.ToArray(); $Ws.Stream.Write($h, 0, $h.Length); $Ws.Stream.Write($masked, 0, $len); $Ws.Stream.Flush()
}
# Returns @{ Opcode; Data } for one complete message (continuation frames joined; pings answered).
function Receive-WsMessage($Ws) {
    $data = New-Object IO.MemoryStream; $opcode = $null
    while ($true) {
        $h = Read-Exact $Ws.Stream 2
        $fin = ($h[0] -band 0x80) -ne 0; $op = $h[0] -band 0x0F
        $len = [long]($h[1] -band 0x7F)
        if ($len -eq 126) { $e = Read-Exact $Ws.Stream 2; $len = $e[0] * 256 + $e[1] }
        elseif ($len -eq 127) { $e = Read-Exact $Ws.Stream 8; $len = 0; foreach ($x in $e) { $len = $len * 256 + $x } }
        if ($h[1] -band 0x80) { $null = Read-Exact $Ws.Stream 4 }  # servers do not mask, but tolerate it
        $payload = if ($len -gt 0) { Read-Exact $Ws.Stream ([int]$len) } else { New-Object byte[] 0 }
        if ($op -eq 9) { Send-WsFrame $Ws $payload 10; continue }    # ping -> pong
        if ($op -eq 10) { continue }                                  # unsolicited pong
        if ($op -ne 0) { $opcode = $op }
        $data.Write($payload, 0, $payload.Length)
        if ($fin) { return @{ Opcode = $opcode; Data = $data.ToArray() } }
    }
}

function Invoke-AriaSpeech {
    # Microsoft Edge read-aloud service. Protocol: speech.config + SSML over a WebSocket,
    # binary frames carry MP3 (2-byte big-endian header length), text frames carry word metadata.
    $token = '6A5AA1D4EAFF4E9FB37E23D68491D6F4'
    $chromium = '143.0.3650.75'; $major = $chromium.Split('.')[0]
    # Sec-MS-GEC: SHA-256 of Windows file time (rounded down to 5 minutes) + client token.
    $unix = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() / 1000.0
    $secs = [math]::Floor(($unix + 11644473600) / 300) * 300
    $ticks = [decimal]$secs * 10000000
    $sha = [Security.Cryptography.SHA256]::Create()
    $gec = -join ($sha.ComputeHash([Text.Encoding]::ASCII.GetBytes("$ticks$token")) | ForEach-Object { $_.ToString('X2') })
    $conn = [guid]::NewGuid().ToString('N')
    $path = "/consumer/speech/synthesize/readaloud/edge/v1?TrustedClientToken=$token&ConnectionId=$conn&Sec-MS-GEC=$gec&Sec-MS-GEC-Version=1-$chromium"
    $muid = -join ((1..16) | ForEach-Object { '{0:X2}' -f (Get-Random -Maximum 256) })
    $headers = [ordered]@{
        'Origin'          = 'chrome-extension://jdiccldimpdaibmpdkjnbmckianbfold'
        'Pragma'          = 'no-cache'
        'Cache-Control'   = 'no-cache'
        'User-Agent'      = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/$major.0.0.0 Safari/537.36 Edg/$major.0.0.0"
        'Accept-Language' = 'en-US,en;q=0.9'
        'Cookie'          = "muid=$muid;"
    }
    try { $ws = Open-RawWebSocket 'speech.platform.bing.com' $path $headers }
    catch {
        $e = $_.Exception; while ($e.InnerException) { $e = $e.InnerException }
        throw "Aria connection failed: $($e.Message). Check internet access, or re-run with -Voice builtin."
    }
    $ws.Tcp.ReceiveTimeout = 60000

    function Send-Text([string]$s) { Send-WsFrame $ws ([Text.Encoding]::UTF8.GetBytes($s)) 1 }
    $stamp = [DateTime]::UtcNow.ToString('ddd MMM dd yyyy HH:mm:ss', [Globalization.CultureInfo]::InvariantCulture) + ' GMT+0000 (Coordinated Universal Time)'
    Send-Text ("X-Timestamp:$stamp`r`nContent-Type:application/json; charset=utf-8`r`nPath:speech.config`r`n`r`n" +
        '{"context":{"synthesis":{"audio":{"metadataoptions":{"sentenceBoundaryEnabled":"false","wordBoundaryEnabled":"true"},"outputFormat":"audio-24khz-48kbitrate-mono-mp3"}}}}' + "`r`n")
    $ssml = "<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' xml:lang='en-US'><voice name='$AriaVoiceName'><prosody pitch='$Pitch' rate='$Rate' volume='$Volume'>$(ConvertTo-XmlText $Text)</prosody></voice></speak>"
    Send-Text ("X-RequestId:$([guid]::NewGuid().ToString('N'))`r`nContent-Type:application/ssml+xml`r`nX-Timestamp:${stamp}Z`r`nPath:ssml`r`n`r`n$ssml")

    $audio = New-Object IO.MemoryStream
    $words = New-Object Collections.Generic.List[object]
    $done = $false
    while (-not $done) {
        $msg = Receive-WsMessage $ws
        $data = $msg.Data
        if ($msg.Opcode -eq 8) { break }
        if ($msg.Opcode -eq 1) {
            $s = [Text.Encoding]::UTF8.GetString($data)
            $split = $s.IndexOf("`r`n`r`n")
            $head = $s.Substring(0, $split); $body = $s.Substring($split + 4)
            if ($head -match 'Path:turn\.end') { $done = $true }
            elseif ($head -match 'Path:audio\.metadata') {
                foreach ($m in ($body | ConvertFrom-Json).Metadata) {
                    if ($m.Type -eq 'WordBoundary') {
                        $start = $m.Data.Offset / 1e7
                        $words.Add([pscustomobject]@{ text = $m.Data.text.Text; start = [math]::Round($start, 3); end = [math]::Round($start + $m.Data.Duration / 1e7, 3) })
                    }
                }
            }
        } elseif ($msg.Opcode -eq 2 -and $data.Length -ge 2) {
            $hl = $data[0] * 256 + $data[1]
            $hdr = [Text.Encoding]::ASCII.GetString($data, 2, [math]::Min($hl, $data.Length - 2))
            if ($hdr -match 'Path:audio' -and $hdr -match 'audio/mpeg' -and $data.Length -gt $hl + 2) {
                $audio.Write($data, $hl + 2, $data.Length - $hl - 2)
            }
        }
    }
    try { Send-WsFrame $ws (New-Object byte[] 0) 8 } catch { }
    $ws.Tcp.Close()
    if ($audio.Length -eq 0) { throw 'Aria returned no audio (service unreachable, blocked, or protocol changed). Re-run with -Voice builtin.' }
    $file = "$OutBase.mp3"
    [IO.File]::WriteAllBytes([IO.Path]::GetFullPath($file), $audio.ToArray())
    # 48 kbit/s constant-bitrate MP3: duration from byte count.
    $duration = $audio.Length * 8 / 48000.0
    @{ file = $file; duration = $duration; words = $words }
}

function Invoke-BuiltinSpeech {
    $synth = [Windows.Media.SpeechSynthesis.SpeechSynthesizer]::new()
    if ($BuiltinVoiceName) {
        $v = [Windows.Media.SpeechSynthesis.SpeechSynthesizer]::AllVoices | Where-Object { $_.DisplayName -like "*$BuiltinVoiceName*" } | Select-Object -First 1
        if (-not $v) { throw "Built-in voice '$BuiltinVoiceName' not found." }
        $synth.Voice = $v
    }
    $synth.Options.IncludeWordBoundaryMetadata = $true
    $stream = Wait-WinRT ($synth.SynthesizeTextToStreamAsync($Text)) ([Windows.Media.SpeechSynthesis.SpeechSynthesisStream])
    $words = New-Object Collections.Generic.List[object]
    foreach ($track in $stream.TimedMetadataTracks) {
        foreach ($cue in $track.Cues) {
            $start = $cue.StartTime.TotalSeconds
            $len = if ($cue.Duration -is [TimeSpan]) { $cue.Duration.TotalSeconds } else { 0 }
            $words.Add([pscustomobject]@{ text = $cue.Text; start = [math]::Round($start, 3); end = [math]::Round($start + $len, 3) })
        }
    }
    $reader = [Windows.Storage.Streams.DataReader]::new($stream.GetInputStreamAt(0))
    [void](Wait-WinRT ($reader.LoadAsync([uint32]$stream.Size)) ([uint32]))
    $bytes = New-Object byte[] $stream.Size; $reader.ReadBytes($bytes)
    $file = "$OutBase.wav"
    [IO.File]::WriteAllBytes([IO.Path]::GetFullPath($file), $bytes)
    # PCM WAV: duration = data bytes / byte rate (byte rate at header offset 28).
    $byteRate = [BitConverter]::ToInt32($bytes, 28)
    @{ file = $file; duration = ($bytes.Length - 44) / $byteRate; words = $words }
}

# Take only the last pipeline object: stray output inside a function would otherwise make this an array.
$result = @($(if ($Voice -eq 'aria') { Invoke-AriaSpeech } else { Invoke-BuiltinSpeech }))[-1]
$meta = [ordered]@{ voice = $(if ($Voice -eq 'aria') { $AriaVoiceName } else { 'builtin' }); text = $Text
                    audio = [IO.Path]::GetFileName([string]$result.file); duration = [math]::Round([double]$result.duration, 3); words = $result.words.ToArray() }
# Note: with WinRT types loaded, PowerShell 5.1's @() on a generic List throws "Argument types do not match"; use .ToArray().
Write-DemoJson $meta "$OutBase.words.json"
"{0}: {1:n2}s, {2} words -> {3}" -f $meta.voice, $meta.duration, $meta.words.Count, $result.file
