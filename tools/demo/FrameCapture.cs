// Screen recorder for the demo-video skills: grabs one monitor at a steady rate, draws the real cursor in,
// and writes numbered JPEGs plus a frames.tsv of (index, UTC ticks). Compiled by Add-Type; no external libraries.
using System;
using System.Collections.Concurrent;
using System.Drawing;
using System.Drawing.Imaging;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading;

namespace DemoKit
{
    public static class FrameCapture
    {
        // Runs until stopFile exists (or maxSeconds passes). Returns the number of frames written.
        public static string Backend;

        // deviceName (e.g. \\.\DISPLAY1) selects DXGI duplication; GDI is the fallback when duplication is unavailable.
        public static int Run(string outDir, string deviceName, int x, int y, int w, int h, double fps, string stopFile, long quality, double maxSeconds)
        {
            Directory.CreateDirectory(outDir);
            var codec = ImageCodecInfo.GetImageEncoders().First(c => c.MimeType == "image/jpeg");
            var queue = new BlockingCollection<Tuple<int, Bitmap>>(48);
            int workers = Math.Max(2, Math.Min(6, Environment.ProcessorCount - 1));
            var threads = Enumerable.Range(0, workers).Select(_ => new Thread(() =>
            {
                var ep = new EncoderParameters(1); ep.Param[0] = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, quality);
                foreach (var item in queue.GetConsumingEnumerable())
                {
                    using (item.Item2) item.Item2.Save(Path.Combine(outDir, string.Format("f{0:D6}.jpg", item.Item1)), codec, ep);
                }
            }) { IsBackground = true }).ToList();
            threads.ForEach(t => t.Start());

            DxgiCapture dx = null;
            try { dx = new DxgiCapture(deviceName); var first = dx.Grab(300); if (first != null) first.Dispose(); x = dx.X; y = dx.Y; w = dx.Width; h = dx.Height; Backend = "dxgi"; }
            catch (Exception e) { if (dx != null) dx.Dispose(); dx = null; Backend = "gdi (" + e.Message + ")"; }
            File.WriteAllText(Path.Combine(outDir, "backend.txt"), Backend);
            File.WriteAllText(Path.Combine(outDir, "READY"), "");   // frames start now
            var log = new StreamWriter(Path.Combine(outDir, "frames.tsv"));
            var sw = Stopwatch.StartNew();
            long interval = (long)(Stopwatch.Frequency / fps);
            long next = 0; int n = 0;
            try
            {
                while (!File.Exists(stopFile) && sw.Elapsed.TotalSeconds < maxSeconds)
                {
                    long now = sw.ElapsedTicks;
                    if (now < next) { Thread.Sleep(Math.Max(1, (int)((next - now) * 1000 / Stopwatch.Frequency) - 1)); continue; }
                    next = Math.Max(next + interval, now - interval); // never try to catch up more than one frame
                    long stamp = DateTime.UtcNow.Ticks;
                    Bitmap bmp;
                    bmp = dx != null ? dx.Grab(0) : null;   // null until DXGI has a real image (static or blank first frame)
                    if (bmp == null) { bmp = new Bitmap(w, h, PixelFormat.Format32bppRgb); using (var g0 = Graphics.FromImage(bmp)) g0.CopyFromScreen(x, y, 0, 0, new Size(w, h), CopyPixelOperation.SourceCopy); }
                    var cur = Win32Input.CursorState();   // cursor is logged, not baked in: the renderer draws it after zooming
                    queue.Add(Tuple.Create(n, bmp));
                    log.WriteLine(n + "\t" + stamp + "\t" + cur[0] + "\t" + cur[1] + "\t" + cur[2] + "\t" + cur[3]);
                    n++;
                }
            }
            finally
            {
                if (dx != null) dx.Dispose();
                queue.CompleteAdding();
                threads.ForEach(t => t.Join());
                log.Dispose();
            }
            return n;
        }
    }
}
