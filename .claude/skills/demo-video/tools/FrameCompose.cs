// Per-frame post-production for the demo-video renderer: zoom/pan crop, crossfade, spotlight, highlight,
// marker sweep, magnified callout ("balloon"), click ripple, burned-in caption. Compiled by Add-Type; System.Drawing only.
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Drawing.Text;
using System.Linq;
using System.Threading.Tasks;

namespace DemoKit
{
    public class Effect
    {
        public string Kind;                 // spotlight | highlight | marker | underline | callout
        public float X, Y, W, H;            // target rectangle in source (captured frame) pixels
        public float P;                     // 0..1 envelope: how far the effect is in (eased by the caller)
        public float Q = 1;                 // 0..1 secondary progress (marker sweep)
        public float Scale = 1.8f;          // callout magnification relative to how big the target looks on screen
        public int Color = unchecked((int)0xFFFFB000);   // ARGB accent
    }

    public class FrameJob
    {
        public string Src, Dst;
        public float CropX, CropY, CropW, CropH;   // source rectangle shown (zoom/pan)
        public string Blend;                        // optional earlier frame to crossfade from (already composed output)
        public float BlendAlpha;                    // 0..1 opacity of Blend over this frame
        public Effect[] Effects;
        public string Caption;
        public bool CaptionTop;                     // force the caption to the top band (scene setting or busy bottom)
        public float RippleX = -1, RippleY = -1, RippleT = -1;
        public float CursorX = -1, CursorY = -1;    // source coordinates; drawn after the zoom at constant size
        public int CursorKind;                       // 0 arrow, 1 hand, 2 text, 3 busy
    }

    public static class FrameCompose
    {
        static readonly ImageCodecInfo Jpeg = ImageCodecInfo.GetImageEncoders().First(c => c.MimeType == "image/jpeg");

        public static void RenderAll(FrameJob[] jobs, int outW, int outH, long quality, string fontName)
        {
            // Frames that blend with an earlier output must wait for it, so render in two passes.
            var first = jobs.Where(j => string.IsNullOrEmpty(j.Blend)).ToArray();
            var second = jobs.Where(j => !string.IsNullOrEmpty(j.Blend)).ToArray();
            var opt = new ParallelOptions { MaxDegreeOfParallelism = Math.Max(2, Environment.ProcessorCount - 1) };
            Parallel.ForEach(first, opt, j => Render(j, outW, outH, quality, fontName));
            Parallel.ForEach(second, opt, j => Render(j, outW, outH, quality, fontName));
        }

        public static void Render(FrameJob j, int outW, int outH, long quality, string fontName)
        {
            using (var src = Image.FromFile(j.Src))
            using (var dst = new Bitmap(outW, outH, PixelFormat.Format24bppRgb))
            using (var g = Graphics.FromImage(dst))
            {
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                g.PixelOffsetMode = PixelOffsetMode.HighQuality;
                g.SmoothingMode = SmoothingMode.AntiAlias;
                var crop = new RectangleF(j.CropX, j.CropY, j.CropW, j.CropH);
                g.DrawImage(src, new RectangleF(0, 0, outW, outH), crop, GraphicsUnit.Pixel);
                float k = outW / 1920f;
                Func<float, float, float, float, RectangleF> toOut = (x, y, w, h) =>
                    new RectangleF((x - crop.X) * outW / crop.Width, (y - crop.Y) * outH / crop.Height, w * outW / crop.Width, h * outH / crop.Height);

                if (j.Effects != null)
                {
                    foreach (var e in j.Effects.Where(e => e.Kind == "spotlight" && e.P > 0)) Spotlight(g, toOut(e.X, e.Y, e.W, e.H), e.P, outW, outH, k);
                    foreach (var e in j.Effects.Where(e => e.Kind == "marker" && e.P > 0)) Marker(g, toOut(e.X, e.Y, e.W, e.H), e, k);
                    foreach (var e in j.Effects.Where(e => e.Kind == "underline" && e.P > 0)) Underline(g, toOut(e.X, e.Y, e.W, e.H), e, k);
                    foreach (var e in j.Effects.Where(e => e.Kind == "highlight" && e.P > 0)) Highlight(g, toOut(e.X, e.Y, e.W, e.H), e, k);
                }
                if (j.RippleT >= 0 && j.RippleT <= 1 && j.RippleX >= 0)
                {
                    var p = toOut(j.RippleX, j.RippleY, 0, 0);
                    float r = (10 + 38 * j.RippleT) * k * (float)Math.Sqrt(outW / crop.Width * crop.Width / outW);
                    int a = (int)(200 * (1 - j.RippleT));
                    using (var fill = new SolidBrush(Color.FromArgb(a / 3, 255, 196, 0)))
                    using (var pen = new Pen(Color.FromArgb(a, 255, 170, 0), 4f * k))
                    { g.FillEllipse(fill, p.X - r, p.Y - r, 2 * r, 2 * r); g.DrawEllipse(pen, p.X - r, p.Y - r, 2 * r, 2 * r); }
                }
                if (j.Effects != null)
                    foreach (var e in j.Effects.Where(e => e.Kind == "callout" && e.P > 0)) Callout(g, src, e, toOut(e.X, e.Y, e.W, e.H), outW, outH, k);
                if (j.CursorX >= 0) DrawCursor(g, toOut(j.CursorX, j.CursorY, 0, 0).Location, j.CursorKind, k);
                if (!string.IsNullOrEmpty(j.Blend) && j.BlendAlpha > 0)
                    using (var prev = Image.FromFile(j.Blend)) DrawFaded(g, prev, new Rectangle(0, 0, outW, outH), j.BlendAlpha);
                if (!string.IsNullOrEmpty(j.Caption))
                {
                    // Captions move to the top band when an effect sits where they would go.
                    bool top = j.CaptionTop || (j.Effects != null && j.Effects.Any(e => e.P > 0 && toOut(e.X, e.Y, e.W, e.H).Bottom > outH * 0.78f));
                    DrawCaption(g, j.Caption, outW, outH, fontName, top);
                }
                SaveJpeg(dst, j.Dst, quality);
            }
        }

        static RectangleF Pad(RectangleF r, float px) { return new RectangleF(r.X - px, r.Y - px, r.Width + 2 * px, r.Height + 2 * px); }

        // Dims everything except the target, through a rounded cut-out.
        static void Spotlight(Graphics g, RectangleF r, float p, int outW, int outH, float k)
        {
            var holeRect = Pad(r, 14 * k);
            int a = (int)(128 * p);                       // about 50% dim: walkthroughs need context
            using (var path = new GraphicsPath { FillMode = FillMode.Alternate })
            using (var hole = RoundRect(holeRect, 12 * k))
            using (var dim = new SolidBrush(Color.FromArgb(a, 8, 10, 18)))
            {
                path.AddRectangle(new RectangleF(0, 0, outW, outH));
                path.AddPath(hole, false);
                g.FillPath(dim, path);
            }
            for (int i = 1; i <= 4; i++)                  // feathered edge: soft rings fading into the hole
                using (var ring = RoundRect(Pad(holeRect, -i * 3 * k), Math.Max(1, (12 - i * 2) * k)))
                using (var pen = new Pen(Color.FromArgb(a * (5 - i) / 10, 8, 10, 18), 3.2f * k)) g.DrawPath(pen, ring);
        }

        // Rounded outline with a soft glow around the target.
        static void Highlight(Graphics g, RectangleF r, Effect e, float k)
        {
            var c = Color.FromArgb(e.Color);
            var box = Pad(r, 8 * k);
            using (var path = RoundRect(box, 8 * k))
            {
                using (var glow = new Pen(Color.FromArgb((int)(60 * e.P), c), 12 * k)) g.DrawPath(glow, path);
                using (var pen = new Pen(Color.FromArgb((int)(255 * e.P), c), 3.5f * k)) g.DrawPath(pen, path);
            }
        }

        // Highlighter-pen sweep across a line of text, left to right.
        static void Marker(Graphics g, RectangleF r, Effect e, float k)
        {
            var c = Color.FromArgb(e.Color);
            float w = (r.Width + 8 * k) * Math.Max(0, Math.Min(1, e.Q));
            using (var b = new SolidBrush(Color.FromArgb((int)(95 * e.P), c)))
            using (var path = RoundRect(new RectangleF(r.X - 4 * k, r.Y + r.Height * 0.08f, Math.Max(1, w), r.Height * 0.9f), 6 * k))
                g.FillPath(b, path);
        }

        // Pen-style underline drawn left to right just under the text baseline.
        static void Underline(Graphics g, RectangleF r, Effect e, float k)
        {
            float w = r.Width * Math.Max(0, Math.Min(1, e.Q));
            if (w < 1) return;
            using (var pen = new Pen(Color.FromArgb((int)(205 * e.P), Color.FromArgb(e.Color)), 5 * k) { StartCap = LineCap.Round, EndCap = LineCap.Round })
                g.DrawLine(pen, r.X, r.Bottom + 3 * k, r.X + w, r.Bottom + 3 * k);
        }

        // Magnified copy of the target in a rounded "balloon" placed beside it (never over it or the caption band).
        static void Callout(Graphics g, Image src, Effect e, RectangleF onScreen, int outW, int outH, float k)
        {
            float pad = Math.Max(e.W, e.H) * 0.10f + 10;
            var srcRect = new RectangleF(e.X - pad, e.Y - pad, e.W + 2 * pad, e.H + 2 * pad);
            float fx = onScreen.Width / Math.Max(1, e.W), fy = onScreen.Height / Math.Max(1, e.H);
            float baseW = srcRect.Width * fx, baseH = srcRect.Height * fy;
            float s = Math.Max(1.2f, Math.Min(2.0f, e.Scale));
            s = Math.Min(s, Math.Min(outW * 0.45f / baseW, outH * 0.4f / baseH));   // a balloon stays a detail, not a second screen
            float fullW = baseW * s, fullH = baseH * s, gap = 28 * k;
            float captionTop = outH * 0.80f;
            var cands = new[] {
                new RectangleF(onScreen.X + onScreen.Width / 2 - fullW / 2, onScreen.Y - gap - fullH, fullW, fullH),     // above
                new RectangleF(onScreen.X + onScreen.Width / 2 - fullW / 2, onScreen.Bottom + gap, fullW, fullH),        // below
                new RectangleF(onScreen.Right + gap, onScreen.Y + onScreen.Height / 2 - fullH / 2, fullW, fullH),        // right
                new RectangleF(onScreen.X - gap - fullW, onScreen.Y + onScreen.Height / 2 - fullH / 2, fullW, fullH) };  // left
            RectangleF box = cands[0]; bool found = false;
            foreach (var cnd in cands)
            {
                var b = new RectangleF(Clamp(cnd.X, 16 * k, outW - cnd.Width - 16 * k), Clamp(cnd.Y, 16 * k, captionTop - cnd.Height - 8 * k), cnd.Width, cnd.Height);
                if (!b.IntersectsWith(Pad(onScreen, 6 * k))) { box = b; found = true; break; }
            }
            if (!found) box = new RectangleF(Clamp(cands[0].X, 16 * k, outW - fullW - 16 * k), 16 * k, fullW, fullH);
            // Pop: 85% -> 100% with at most ~5% overshoot, scaled about the balloon centre.
            float t = Math.Max(0, Math.Min(1, e.P));
            float sc = 0.85f + 0.15f * EaseOutBack(t);
            var cx = box.X + box.Width / 2; var cy = box.Y + box.Height / 2;
            box = new RectangleF(cx - box.Width * sc / 2, cy - box.Height * sc / 2, box.Width * sc, box.Height * sc);
            int alpha = (int)(255 * Math.Min(1, t * 1.8f));
            float radius = 14 * k;
            // Leader line from the target to the balloon.
            var from = new PointF(Clamp(cx, onScreen.X, onScreen.Right), Clamp(cy, onScreen.Y, onScreen.Bottom));
            var to = new PointF(Clamp(from.X, box.X + radius, box.Right - radius), Clamp(from.Y, box.Y, box.Bottom));
            using (var lead = new Pen(Color.FromArgb(alpha, Color.FromArgb(e.Color)), 2.5f * k)) g.DrawLine(lead, from, to);
            using (var ring = new Pen(Color.FromArgb(alpha, Color.FromArgb(e.Color)), 2.5f * k)) g.DrawPath(ring, RoundRect(Pad(onScreen, 4 * k), 6 * k));
            using (var shadow = RoundRect(new RectangleF(box.X + 4 * k, box.Y + 8 * k, box.Width, box.Height), radius))
            using (var sb = new SolidBrush(Color.FromArgb(alpha / 3, 0, 0, 0))) g.FillPath(sb, shadow);
            using (var path = RoundRect(box, radius))
            {
                var state = g.Save();
                g.SetClip(path);
                if (alpha >= 250) g.DrawImage(src, box, srcRect, GraphicsUnit.Pixel);
                else using (var tmp = new Bitmap((int)Math.Max(1, box.Width), (int)Math.Max(1, box.Height)))
                {
                    using (var tg = Graphics.FromImage(tmp)) { tg.InterpolationMode = InterpolationMode.HighQualityBicubic; tg.DrawImage(src, new RectangleF(0, 0, tmp.Width, tmp.Height), srcRect, GraphicsUnit.Pixel); }
                    DrawFaded(g, tmp, Rectangle.Round(box), alpha / 255f);
                }
                g.Restore(state);
                using (var pen = new Pen(Color.FromArgb(alpha, Color.White), 2 * k)) g.DrawPath(pen, path);
            }
        }

        // The pointer, redrawn after zooming so it keeps a constant on-screen size (real shape: arrow, hand or text).
        static readonly System.Windows.Forms.Cursor[] Pointers = { System.Windows.Forms.Cursors.Arrow, System.Windows.Forms.Cursors.Hand, System.Windows.Forms.Cursors.IBeam, System.Windows.Forms.Cursors.AppStarting };
        static readonly object PointerLock = new object();
        static void DrawCursor(Graphics g, PointF at, int kind, float k)
        {
            var cur = Pointers[Math.Max(0, Math.Min(Pointers.Length - 1, kind))];
            float size = 34 * k, scale = size / cur.Size.Width;
            var hs = cur.HotSpot;
            var rect = new Rectangle((int)(at.X - hs.X * scale), (int)(at.Y - hs.Y * scale), (int)size, (int)(cur.Size.Height * scale));
            lock (PointerLock) cur.DrawStretched(g, rect);
        }

        static float Clamp(float v, float lo, float hi) { return hi < lo ? lo : Math.Max(lo, Math.Min(hi, v)); }
        static float EaseOutBack(float x)
        {
            x = Math.Max(0, Math.Min(1, x));
            const float c1 = 1.25f, c3 = c1 + 1;   // gentle overshoot (about 6%)
            return 1 + c3 * (float)Math.Pow(x - 1, 3) + c1 * (float)Math.Pow(x - 1, 2);
        }

        static void DrawFaded(Graphics g, Image img, Rectangle dest, float alpha)
        {
            using (var ia = new ImageAttributes())
            {
                ia.SetColorMatrix(new ColorMatrix { Matrix33 = Math.Max(0, Math.Min(1, alpha)) });
                g.DrawImage(img, dest, 0, 0, img.Width, img.Height, GraphicsUnit.Pixel, ia);
            }
        }

        // Lower-third caption: white text on a translucent dark rounded box, wrapped to two lines at most.
        public static void DrawCaption(Graphics g, string text, int outW, int outH, string fontName) { DrawCaption(g, text, outW, outH, fontName, false); }
        public static void DrawCaption(Graphics g, string text, int outW, int outH, string fontName, bool top)
        {
            g.TextRenderingHint = TextRenderingHint.AntiAliasGridFit;
            float size = outH * 0.034f;
            using (var font = new Font(fontName, size, FontStyle.Regular, GraphicsUnit.Pixel))
            using (var fmt = new StringFormat { Alignment = StringAlignment.Center, LineAlignment = StringAlignment.Center })
            {
                float maxW = outW * 0.78f;
                var measured = g.MeasureString(text, font, (int)maxW, fmt);
                float padX = size * 0.8f, padY = size * 0.45f;
                float w = measured.Width + 2 * padX, h = measured.Height + 2 * padY;
                float x = (outW - w) / 2, y = top ? outH * 0.05f : outH - h - outH * 0.06f;
                using (var path = RoundRect(new RectangleF(x, y, w, h), size * 0.45f))
                using (var bg = new SolidBrush(Color.FromArgb(185, 12, 14, 20)))
                    g.FillPath(bg, path);
                g.DrawString(text, font, Brushes.White, new RectangleF(x + padX, y + padY, measured.Width, measured.Height), fmt);
            }
        }

        // Full-frame title card (opening and closing cards).
        public static void TitleCard(string dstPath, int outW, int outH, string title, string subtitle, string fontName, long quality, int colorA, int colorB)
        {
            using (var bmp = new Bitmap(outW, outH, PixelFormat.Format24bppRgb))
            using (var g = Graphics.FromImage(bmp))
            {
                g.SmoothingMode = SmoothingMode.AntiAlias; g.TextRenderingHint = TextRenderingHint.AntiAliasGridFit;
                using (var bg = new LinearGradientBrush(new Rectangle(0, 0, outW, outH), Color.FromArgb(colorA), Color.FromArgb(colorB), 35f))
                    g.FillRectangle(bg, 0, 0, outW, outH);
                using (var fmt = new StringFormat { Alignment = StringAlignment.Center, LineAlignment = StringAlignment.Center })
                using (var big = new Font(fontName, outH * 0.075f, FontStyle.Bold, GraphicsUnit.Pixel))
                using (var small = new Font(fontName, outH * 0.035f, FontStyle.Regular, GraphicsUnit.Pixel))
                using (var soft = new SolidBrush(Color.FromArgb(215, 255, 255, 255)))
                {
                    g.DrawString(title ?? "", big, Brushes.White, new RectangleF(outW * 0.1f, outH * 0.30f, outW * 0.8f, outH * 0.25f), fmt);
                    if (!string.IsNullOrEmpty(subtitle))
                        g.DrawString(subtitle, small, soft, new RectangleF(outW * 0.1f, outH * 0.55f, outW * 0.8f, outH * 0.12f), fmt);
                }
                SaveJpeg(bmp, dstPath, quality);
            }
        }

        // Crossfade frames between two still images (used for transitions between clips).
        public static void Crossfade(string fromPath, string toPath, string dstPattern, int frames, int outW, int outH, long quality)
        {
            using (var a = Image.FromFile(fromPath))
            using (var b = Image.FromFile(toPath))
                for (int i = 0; i < frames; i++)
                {
                    float t = (i + 0.5f) / frames; t = t * t * (3 - 2 * t);
                    using (var bmp = new Bitmap(outW, outH, PixelFormat.Format24bppRgb))
                    using (var g = Graphics.FromImage(bmp))
                    {
                        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                        g.DrawImage(a, new Rectangle(0, 0, outW, outH));
                        DrawFaded(g, b, new Rectangle(0, 0, outW, outH), t);
                        SaveJpeg(bmp, string.Format(dstPattern, i), quality);
                    }
                }
        }

        // Mean absolute difference (0..255) between consecutive frames on a small grid: finds idle stretches to trim.
        // Each frame is decoded once, in parallel; result[k] compares frame k-1 with frame k (result[0] = 0).
        public static double[] Differences(string[] paths)
        {
            var thumbs = new byte[paths.Length][];
            Parallel.For(0, paths.Length, new ParallelOptions { MaxDegreeOfParallelism = Math.Max(2, Environment.ProcessorCount - 1) }, k =>
            {
                using (var img = Image.FromFile(paths[k])) using (var s = new Bitmap(img, 96, 60))
                {
                    var px = new byte[96 * 60 * 3]; int o = 0;
                    for (int y = 0; y < 60; y++) for (int x = 0; x < 96; x++) { Color c = s.GetPixel(x, y); px[o++] = c.R; px[o++] = c.G; px[o++] = c.B; }
                    thumbs[k] = px;
                }
            });
            var d = new double[paths.Length];
            for (int k = 1; k < paths.Length; k++) { long sum = 0; var a = thumbs[k - 1]; var b = thumbs[k]; for (int i = 0; i < a.Length; i++) sum += Math.Abs(a[i] - b[i]); d[k] = sum / (double)a.Length; }
            return d;
        }

        // Mean absolute difference (0..255) between two frames on a small grid: finds idle stretches to trim.
        public static double Difference(string pathA, string pathB)
        {
            using (var a = Image.FromFile(pathA)) using (var b = Image.FromFile(pathB))
            using (var sa = new Bitmap(a, 96, 60)) using (var sb = new Bitmap(b, 96, 60))
            {
                double sum = 0;
                for (int y = 0; y < 60; y++)
                    for (int x = 0; x < 96; x++)
                    {
                        Color p = sa.GetPixel(x, y), q = sb.GetPixel(x, y);
                        sum += Math.Abs(p.R - q.R) + Math.Abs(p.G - q.G) + Math.Abs(p.B - q.B);
                    }
                return sum / (96 * 60 * 3);
            }
        }

        static GraphicsPath RoundRect(RectangleF r, float rad)
        {
            var p = new GraphicsPath(); float d = Math.Min(2 * rad, Math.Min(r.Width, r.Height));
            if (d < 1) { p.AddRectangle(r); return p; }
            p.AddArc(r.X, r.Y, d, d, 180, 90); p.AddArc(r.Right - d, r.Y, d, d, 270, 90);
            p.AddArc(r.Right - d, r.Bottom - d, d, d, 0, 90); p.AddArc(r.X, r.Bottom - d, d, d, 90, 90);
            p.CloseFigure(); return p;
        }

        static void SaveJpeg(Image img, string path, long quality)
        {
            var ep = new EncoderParameters(1); ep.Param[0] = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, quality);
            img.Save(path, Jpeg, ep);
        }
    }
}
