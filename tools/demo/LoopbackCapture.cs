// Records what the speakers play (WASAPI loopback, built into Windows) to a 16-bit PCM WAV, so an app's own sound
// (for example a talking chat agent) can be kept in the demo. Silence is written while nothing plays, so the file
// stays in step with the wall clock; a levels log lets the recorder wait until the app has finished speaking.
// COM calls go through raw vtable slots: no interface declarations, no external libraries.
using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;

namespace DemoKit
{
    public static class LoopbackCapture
    {
        [DllImport("ole32.dll")] static extern int CoCreateInstance(ref Guid clsid, IntPtr outer, uint ctx, ref Guid iid, out IntPtr obj);
        [DllImport("ole32.dll")] static extern int CoInitializeEx(IntPtr r, uint model);
        [DllImport("ole32.dll")] static extern void CoTaskMemFree(IntPtr p);

        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate uint ReleaseFn(IntPtr self);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int GetDefaultFn(IntPtr self, int flow, int role, out IntPtr dev);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int ActivateFn(IntPtr self, ref Guid iid, uint ctx, IntPtr p, out IntPtr obj);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int InitFn(IntPtr self, int share, uint flags, long buffer, long period, IntPtr fmt, IntPtr session);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int MixFmtFn(IntPtr self, out IntPtr fmt);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int NoArgFn(IntPtr self);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int ServiceFn(IntPtr self, ref Guid iid, out IntPtr obj);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int GetBufferFn(IntPtr self, out IntPtr data, out uint frames, out uint flags, out ulong devPos, out ulong qpcPos);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int ReleaseBufferFn(IntPtr self, uint frames);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int NextPacketFn(IntPtr self, out uint frames);

        static T Slot<T>(IntPtr obj, int slot) where T : class
        { return (T)(object)Marshal.GetDelegateForFunctionPointer(Marshal.ReadIntPtr(Marshal.ReadIntPtr(obj), slot * IntPtr.Size), typeof(T)); }
        static void Release(ref IntPtr p) { if (p != IntPtr.Zero) { Slot<ReleaseFn>(p, 2)(p); p = IntPtr.Zero; } }
        static void Check(int hr, string what) { if (hr < 0) throw new InvalidOperationException(string.Format("{0} failed: 0x{1:X8}", what, hr)); }

        public static long StartedUtcTicks;   // wall-clock time of the first sample written
        public static int SampleRate, Channels;
        public static string Error;

        // Records until stopFile exists. Writes wavPath and levelsPath ("utcTicks<TAB>rms 0..1" every ~50 ms).
        public static void Run(string wavPath, string levelsPath, string stopFile, double maxSeconds)
        {
            CoInitializeEx(IntPtr.Zero, 0); // multithreaded
            IntPtr enumr = IntPtr.Zero, dev = IntPtr.Zero, client = IntPtr.Zero, capture = IntPtr.Zero, fmt = IntPtr.Zero;
            try
            {
                Guid clsidEnum = new Guid("BCDE0395-E52F-467C-8E3D-C4579291692E"), iidEnum = new Guid("A95664D2-9614-4F35-A746-DE8DB63617E6");
                Guid iidClient = new Guid("1CB9AD4C-DBFA-4c32-B178-C2F568A703B2"), iidCapture = new Guid("C8ADBD64-E71E-48a0-A4DE-185C395CD317");
                Check(CoCreateInstance(ref clsidEnum, IntPtr.Zero, 0x17, ref iidEnum, out enumr), "MMDeviceEnumerator");
                Check(Slot<GetDefaultFn>(enumr, 4)(enumr, 0 /*eRender*/, 1 /*eMultimedia*/, out dev), "GetDefaultAudioEndpoint");
                Check(Slot<ActivateFn>(dev, 3)(dev, ref iidClient, 0x17, IntPtr.Zero, out client), "Activate(IAudioClient)");
                Check(Slot<MixFmtFn>(client, 8)(client, out fmt), "GetMixFormat");
                ushort tag = (ushort)Marshal.ReadInt16(fmt, 0);
                Channels = Marshal.ReadInt16(fmt, 2); SampleRate = Marshal.ReadInt32(fmt, 4);
                int bits = Marshal.ReadInt16(fmt, 14), blockAlign = Marshal.ReadInt16(fmt, 12);
                bool isFloat = tag == 3 || (tag == 0xFFFE && bits == 32 && Marshal.ReadInt32(fmt, 24) == 3);   // KSDATAFORMAT_SUBTYPE_IEEE_FLOAT starts with 3
                Check(Slot<InitFn>(client, 3)(client, 0, 0x00020000 /*LOOPBACK*/, 2000000 /*200 ms*/, 0, fmt, IntPtr.Zero), "IAudioClient.Initialize");
                Check(Slot<ServiceFn>(client, 14)(client, ref iidCapture, out capture), "GetService(IAudioCaptureClient)");

                using (var fs = new FileStream(wavPath, FileMode.Create, FileAccess.Write))
                using (var bw = new BinaryWriter(fs))
                using (var levels = new StreamWriter(levelsPath) { AutoFlush = true })
                {
                    WriteHeader(bw, SampleRate, Channels, 0);
                    long written = 0;                                  // frames written so far
                    var sw = Stopwatch.StartNew();
                    StartedUtcTicks = DateTime.UtcNow.Ticks;
                    Check(Slot<NoArgFn>(client, 10)(client), "Start");
                    double sumSq = 0; long sumN = 0; long lastLevel = 0;
                    var pcm = new byte[0];
                    while (!File.Exists(stopFile) && sw.Elapsed.TotalSeconds < maxSeconds)
                    {
                        Thread.Sleep(10);
                        uint packet;
                        while (Slot<NextPacketFn>(capture, 5)(capture, out packet) >= 0 && packet > 0)
                        {
                            IntPtr data; uint frames, flags; ulong devPos, qpc;
                            Check(Slot<GetBufferFn>(capture, 3)(capture, out data, out frames, out flags, out devPos, out qpc), "GetBuffer");
                            int n = (int)frames * Channels;
                            if (pcm.Length < n * 2) pcm = new byte[n * 2];
                            bool silent = (flags & 0x2) != 0;
                            for (int i = 0; i < n; i++)
                            {
                                float v = 0;
                                if (!silent)
                                {
                                    if (isFloat) v = BitConverter.ToSingle(BitConverter.GetBytes(Marshal.ReadInt32(data, i * 4)), 0);
                                    else if (bits == 16) v = Marshal.ReadInt16(data, i * 2) / 32768f;
                                    else if (bits == 32) v = Marshal.ReadInt32(data, i * 4) / 2147483648f;
                                }
                                v = Math.Max(-1f, Math.Min(1f, v));
                                sumSq += v * v; sumN++;
                                short s = (short)(v * 32767);
                                pcm[i * 2] = (byte)s; pcm[i * 2 + 1] = (byte)(s >> 8);
                            }
                            bw.Write(pcm, 0, n * 2); written += frames;
                            Slot<ReleaseBufferFn>(capture, 4)(capture, frames);
                        }
                        // Nothing playing: Windows sends no packets at all, so pad with silence to keep time.
                        long due = (long)(sw.Elapsed.TotalSeconds * SampleRate) - (SampleRate / 10);   // allow 100 ms of buffering
                        if (due > written)
                        {
                            int pad = (int)(due - written) * Channels * 2;
                            bw.Write(new byte[pad]); written = due;
                        }
                        if (sw.ElapsedMilliseconds - lastLevel >= 50)
                        {
                            double rms = sumN > 0 ? Math.Sqrt(sumSq / sumN) : 0;
                            levels.WriteLine(DateTime.UtcNow.Ticks + "\t" + rms.ToString("0.00000", System.Globalization.CultureInfo.InvariantCulture));
                            sumSq = 0; sumN = 0; lastLevel = sw.ElapsedMilliseconds;
                        }
                    }
                    Slot<NoArgFn>(client, 11)(client);
                    bw.Flush();
                    fs.Seek(0, SeekOrigin.Begin);
                    WriteHeader(bw, SampleRate, Channels, written * Channels * 2);
                }
            }
            catch (Exception e) { Error = e.Message; throw; }
            finally
            {
                if (fmt != IntPtr.Zero) CoTaskMemFree(fmt);
                Release(ref capture); Release(ref client); Release(ref dev); Release(ref enumr);
            }
        }

        static void WriteHeader(BinaryWriter w, int rate, int ch, long dataBytes)
        {
            w.Write(new[] { 'R', 'I', 'F', 'F' }); w.Write((int)(36 + dataBytes)); w.Write(new[] { 'W', 'A', 'V', 'E' });
            w.Write(new[] { 'f', 'm', 't', ' ' }); w.Write(16); w.Write((short)1); w.Write((short)ch); w.Write(rate);
            w.Write(rate * ch * 2); w.Write((short)(ch * 2)); w.Write((short)16);
            w.Write(new[] { 'd', 'a', 't', 'a' }); w.Write((int)dataBytes);
        }

        // Runs Run() on a background thread (PowerShell script blocks cannot run on raw threads).
        public static Thread Start(string wavPath, string levelsPath, string stopFile, double maxSeconds)
        {
            var t = new Thread(() => { try { Run(wavPath, levelsPath, stopFile, maxSeconds); } catch { } }) { IsBackground = true };
            t.Start(); return t;
        }

        // Copies [fromUtc, toUtc) of a recorded WAV into a new WAV (used to give each scene take its own audio).
        public static void Slice(string srcWav, long srcStartUtc, string dstWav, long fromUtc, long toUtc)
        {
            using (var src = new BinaryReader(File.OpenRead(srcWav)))
            {
                src.BaseStream.Seek(22, SeekOrigin.Begin); int ch = src.ReadInt16(); int rate = src.ReadInt32();
                long total = (src.BaseStream.Length - 44) / (ch * 2);
                long a = Math.Max(0, (fromUtc - srcStartUtc) * rate / 10000000), b = Math.Min(total, (toUtc - srcStartUtc) * rate / 10000000);
                if (b < a) b = a;
                using (var dst = new BinaryWriter(File.Create(dstWav)))
                {
                    WriteHeader(dst, rate, ch, (b - a) * ch * 2);
                    src.BaseStream.Seek(44 + a * ch * 2, SeekOrigin.Begin);
                    var buf = new byte[65536]; long left = (b - a) * ch * 2;
                    while (left > 0) { int r = src.Read(buf, 0, (int)Math.Min(buf.Length, left)); if (r <= 0) break; dst.Write(buf, 0, r); left -= r; }
                }
            }
        }
    }
}
