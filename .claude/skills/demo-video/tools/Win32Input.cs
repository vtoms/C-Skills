// Win32 input and window helpers for the demo-video skills.
// Compiled at runtime by Add-Type (the C# compiler that ships with .NET Framework). No external libraries.
using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Threading;

namespace DemoKit
{
    public static class Win32Input
    {
        [StructLayout(LayoutKind.Sequential)] struct MOUSEINPUT { public int dx, dy; public uint mouseData, dwFlags, time; public IntPtr dwExtraInfo; }
        [StructLayout(LayoutKind.Sequential)] struct KEYBDINPUT { public ushort wVk, wScan; public uint dwFlags, time; public IntPtr dwExtraInfo; }
        [StructLayout(LayoutKind.Explicit)] struct INPUTUNION { [FieldOffset(0)] public MOUSEINPUT mi; [FieldOffset(0)] public KEYBDINPUT ki; }
        [StructLayout(LayoutKind.Sequential)] struct INPUT { public uint type; public INPUTUNION u; }
        [StructLayout(LayoutKind.Sequential)] public struct POINT { public int X, Y; }
        [StructLayout(LayoutKind.Sequential)] struct CURSORINFO { public int cbSize, flags; public IntPtr hCursor; public POINT pt; }
        [StructLayout(LayoutKind.Sequential)] struct ICONINFO { public bool fIcon; public int xHotspot, yHotspot; public IntPtr hbmMask, hbmColor; }
        [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }

        [DllImport("user32.dll", SetLastError = true)] static extern uint SendInput(uint n, INPUT[] inputs, int size);
        [DllImport("user32.dll")] static extern bool SetCursorPos(int x, int y);
        [DllImport("user32.dll")] static extern bool GetCursorPos(out POINT p);
        [DllImport("user32.dll")] static extern bool GetCursorInfo(ref CURSORINFO ci);
        [DllImport("user32.dll")] static extern bool GetIconInfo(IntPtr h, out ICONINFO ii);
        [DllImport("user32.dll")] static extern bool DrawIconEx(IntPtr hdc, int x, int y, IntPtr h, int w, int hgt, int step, IntPtr brush, int flags);
        [DllImport("gdi32.dll")] static extern bool DeleteObject(IntPtr h);
        [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
        [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
        [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr h, int x, int y, int w, int hgt, bool repaint);
        [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
        [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
        [DllImport("user32.dll")] static extern bool IsIconic(IntPtr h);
        [DllImport("user32.dll")] static extern IntPtr LoadCursor(IntPtr inst, int id);
        [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern short VkKeyScan(char ch);
        // Virtual-key code for a character on the current keyboard layout (for shortcuts like Ctrl+/ ).
        public static ushort VkFor(char c) { short r = VkKeyScan(c); if (r == -1) throw new ArgumentException("No key for '" + c + "' on this keyboard layout"); return (ushort)(r & 0xFF); }
        delegate bool EnumProc(IntPtr h, IntPtr l);
        [DllImport("user32.dll")] static extern bool EnumChildWindows(IntPtr parent, EnumProc cb, IntPtr l);
        [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetClassName(IntPtr h, System.Text.StringBuilder sb, int max);

        // Child windows of a given class (e.g. the browser's page window, Chrome_RenderWidgetHostHWND).
        public static IntPtr[] ChildWindows(IntPtr parent, string className)
        {
            var found = new System.Collections.Generic.List<IntPtr>();
            EnumChildWindows(parent, (h, l) => { var sb = new System.Text.StringBuilder(256); GetClassName(h, sb, 256); if (sb.ToString() == className) found.Add(h); return true; }, IntPtr.Zero);
            return found.ToArray();
        }
        [DllImport("user32.dll")] static extern void keybd_event(byte vk, byte scan, uint flags, IntPtr extra);

        const uint INPUT_MOUSE = 0, INPUT_KEYBOARD = 1;
        const uint MOUSEEVENTF_LEFTDOWN = 0x2, MOUSEEVENTF_LEFTUP = 0x4, MOUSEEVENTF_RIGHTDOWN = 0x8, MOUSEEVENTF_RIGHTUP = 0x10, MOUSEEVENTF_WHEEL = 0x800;
        const uint KEYEVENTF_KEYUP = 0x2, KEYEVENTF_UNICODE = 0x4;

        static void Send(INPUT i) { SendInput(1, new[] { i }, Marshal.SizeOf(typeof(INPUT))); }
        static void Mouse(uint flags, uint data = 0) { var i = new INPUT { type = INPUT_MOUSE }; i.u.mi.dwFlags = flags; i.u.mi.mouseData = data; Send(i); }
        static void Key(ushort vk, bool up) { var i = new INPUT { type = INPUT_KEYBOARD }; i.u.ki.wVk = vk; i.u.ki.dwFlags = up ? KEYEVENTF_KEYUP : 0; Send(i); }
        static void Unicode(char c, bool up) { var i = new INPUT { type = INPUT_KEYBOARD }; i.u.ki.wScan = c; i.u.ki.dwFlags = KEYEVENTF_UNICODE | (up ? KEYEVENTF_KEYUP : 0); Send(i); }

        public static POINT CursorPosition() { POINT p; GetCursorPos(out p); return p; }

        // Moves the real cursor along an eased path (smoothstep) so the recording shows natural motion.
        public static void Glide(int x, int y, int durationMs)
        {
            // Clock-driven: Thread.Sleep granularity is ~15.6 ms, so counting fixed steps would stretch the glide.
            POINT s; GetCursorPos(out s);
            var sw = System.Diagnostics.Stopwatch.StartNew();
            while (sw.ElapsedMilliseconds < durationMs)
            {
                double t = (double)sw.ElapsedMilliseconds / durationMs; t = t * t * (3 - 2 * t);
                SetCursorPos((int)Math.Round(s.X + (x - s.X) * t), (int)Math.Round(s.Y + (y - s.Y) * t));
                Thread.Sleep(5);
            }
            SetCursorPos(x, y);
        }
        public static void Click(bool right = false, int holdMs = 60)
        {
            Mouse(right ? MOUSEEVENTF_RIGHTDOWN : MOUSEEVENTF_LEFTDOWN); Thread.Sleep(holdMs);
            Mouse(right ? MOUSEEVENTF_RIGHTUP : MOUSEEVENTF_LEFTUP);
        }
        public static void DoubleClick() { Click(false, 30); Thread.Sleep(60); Click(false, 30); }
        public static void Wheel(int notches) { Mouse(MOUSEEVENTF_WHEEL, unchecked((uint)(notches * 120))); }

        // Types text with Unicode key events (layout-independent), at a human-like pace.
        public static void TypeText(string text, int perCharMs)
        {
            var sw = System.Diagnostics.Stopwatch.StartNew(); int k = 0;
            foreach (char c in text)
            {
                if (c == '\n') { KeyPress(0x0D); }
                else { Unicode(c, false); Unicode(c, true); }
                k++;
                long due = (long)k * perCharMs - sw.ElapsedMilliseconds;   // clock-driven so the pace is exact
                if (due > 0) Thread.Sleep((int)due);
            }
        }
        public static void KeyPress(ushort vk) { Key(vk, false); Key(vk, true); }
        // Chords like Ctrl+L: press modifiers in order, release in reverse.
        public static void Chord(ushort[] vks)
        {
            foreach (var v in vks) { Key(v, false); Thread.Sleep(15); }
            for (int i = vks.Length - 1; i >= 0; i--) { Key(vks[i], true); Thread.Sleep(15); }
        }
        // Foreground activation: an ALT tap lets a background process take focus.
        public static bool Activate(IntPtr hwnd)
        {
            keybd_event(0x12, 0, 0, IntPtr.Zero); keybd_event(0x12, 0, KEYEVENTF_KEYUP, IntPtr.Zero);
            if (IsIconic(hwnd)) ShowWindow(hwnd, 9); // SW_RESTORE only when minimised; restoring a maximised window un-maximises it
            return SetForegroundWindow(hwnd);
        }

        // Cursor position and shape for the frame log: x, y, kind (0 arrow, 1 hand, 2 text, 3 busy, 4 other), visible.
        // The renderer redraws the cursor after zooming, so it keeps a constant on-screen size.
        static readonly IntPtr Arrow = LoadCursor(IntPtr.Zero, 32512), Hand = LoadCursor(IntPtr.Zero, 32649), IBeam = LoadCursor(IntPtr.Zero, 32513),
                               Wait = LoadCursor(IntPtr.Zero, 32514), Busy = LoadCursor(IntPtr.Zero, 32650);
        public static int[] CursorState()
        {
            var ci = new CURSORINFO { cbSize = Marshal.SizeOf(typeof(CURSORINFO)) };
            if (!GetCursorInfo(ref ci)) { POINT p; GetCursorPos(out p); return new[] { p.X, p.Y, 0, 1 }; }
            int kind = ci.hCursor == Arrow ? 0 : ci.hCursor == Hand ? 1 : ci.hCursor == IBeam ? 2 : (ci.hCursor == Wait || ci.hCursor == Busy) ? 3 : 4;
            return new[] { ci.pt.X, ci.pt.Y, kind, ci.flags == 1 ? 1 : 0 };
        }

        // Draws the current cursor (real shape, hotspot-aligned) into a captured frame.
        public static void DrawCursor(Graphics g, int originX, int originY)
        {
            var ci = new CURSORINFO { cbSize = Marshal.SizeOf(typeof(CURSORINFO)) };
            if (!GetCursorInfo(ref ci) || ci.flags != 1) return;
            ICONINFO ii; int hx = 0, hy = 0;
            if (GetIconInfo(ci.hCursor, out ii)) { hx = ii.xHotspot; hy = ii.yHotspot; if (ii.hbmMask != IntPtr.Zero) DeleteObject(ii.hbmMask); if (ii.hbmColor != IntPtr.Zero) DeleteObject(ii.hbmColor); }
            IntPtr hdc = g.GetHdc();
            try { DrawIconEx(hdc, ci.pt.X - originX - hx, ci.pt.Y - originY - hy, ci.hCursor, 0, 0, 0, IntPtr.Zero, 3); }
            finally { g.ReleaseHdc(hdc); }
        }
    }
}
