// Fast monitor capture with the DXGI Desktop Duplication API (dxgi.dll + d3d11.dll, part of Windows).
// GDI screen copies cost ~100 ms per frame at 2560x1600 when a GPU-composited window fills the screen;
// duplication hands over the composed frame on the GPU and costs a few milliseconds.
// COM calls go through raw vtable slots so no interface declarations or external libraries are needed.
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

namespace DemoKit
{
    public sealed class DxgiCapture : IDisposable
    {
        [DllImport("dxgi.dll")] static extern int CreateDXGIFactory1(ref Guid riid, out IntPtr factory);
        [DllImport("d3d11.dll")] static extern int D3D11CreateDevice(IntPtr adapter, int driverType, IntPtr software, uint flags,
            IntPtr levels, uint numLevels, uint sdk, out IntPtr device, out int level, out IntPtr context);

        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate uint ReleaseFn(IntPtr self);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int QueryFn(IntPtr self, ref Guid iid, out IntPtr obj);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int EnumFn(IntPtr self, uint index, out IntPtr obj);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int GetDescFn(IntPtr self, IntPtr desc);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int DuplicateFn(IntPtr self, IntPtr device, out IntPtr dup);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int AcquireFn(IntPtr self, uint timeoutMs, IntPtr info, out IntPtr resource);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int ReleaseFrameFn(IntPtr self);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int CreateTexFn(IntPtr self, IntPtr desc, IntPtr data, out IntPtr tex);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void CopyResourceFn(IntPtr self, IntPtr dst, IntPtr src);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int MapFn(IntPtr self, IntPtr res, uint sub, int type, uint flags, IntPtr mapped);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void UnmapFn(IntPtr self, IntPtr res, uint sub);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void TexDescFn(IntPtr self, IntPtr desc);

        static T Slot<T>(IntPtr obj, int slot) where T : class
        {
            IntPtr fn = Marshal.ReadIntPtr(Marshal.ReadIntPtr(obj), slot * IntPtr.Size);
            return (T)(object)Marshal.GetDelegateForFunctionPointer(fn, typeof(T));
        }
        static void Release(ref IntPtr p) { if (p != IntPtr.Zero) { Slot<ReleaseFn>(p, 2)(p); p = IntPtr.Zero; } }
        static void Check(int hr, string what) { if (hr < 0) throw new InvalidOperationException(string.Format("{0} failed: 0x{1:X8}", what, hr)); }

        const int WAIT_TIMEOUT = unchecked((int)0x887A0027), ACCESS_LOST = unchecked((int)0x887A0026);
        IntPtr device, context, output1, dup, staging;
        public int X, Y, Width, Height;
        Bitmap last;

        // deviceName is a monitor name such as \\.\DISPLAY1 (System.Windows.Forms.Screen.DeviceName).
        public DxgiCapture(string deviceName)
        {
            Guid iidFactory1 = new Guid("770aae78-f26f-4dba-a829-253c83d1b387");
            // IDXGIOutput6, 5 and 2 all derive from IDXGIOutput1, so DuplicateOutput sits at the same vtable slot (22).
            string[] outputIids = { "068346e8-aaec-4b84-add7-137f513f77a1", "80a07424-ab52-42eb-833c-0c42fd282d98", "595e39d1-2724-4663-99b1-da969de28364" };
            IntPtr factory; Check(CreateDXGIFactory1(ref iidFactory1, out factory), "CreateDXGIFactory1");
            IntPtr desc = Marshal.AllocHGlobal(256);
            try
            {
                for (uint a = 0; output1 == IntPtr.Zero; a++)
                {
                    IntPtr adapter; if (Slot<EnumFn>(factory, 12)(factory, a, out adapter) < 0) break;   // EnumAdapters1
                    for (uint o = 0; ; o++)
                    {
                        IntPtr output; if (Slot<EnumFn>(adapter, 7)(adapter, o, out output) < 0) break;    // EnumOutputs
                        Check(Slot<GetDescFn>(output, 7)(output, desc), "IDXGIOutput.GetDesc");
                        string name = Marshal.PtrToStringUni(desc, 32).TrimEnd('\0');
                        if (string.Equals(name, deviceName, StringComparison.OrdinalIgnoreCase))
                        {
                            X = Marshal.ReadInt32(desc, 64); Y = Marshal.ReadInt32(desc, 68);
                            Width = Marshal.ReadInt32(desc, 72) - X; Height = Marshal.ReadInt32(desc, 76) - Y;
                            int level; Check(D3D11CreateDevice(adapter, 0, IntPtr.Zero, 0, IntPtr.Zero, 0, 7, out device, out level, out context), "D3D11CreateDevice");
                            foreach (var s in outputIids) { Guid g = new Guid(s); if (Slot<QueryFn>(output, 0)(output, ref g, out output1) >= 0) break; output1 = IntPtr.Zero; }
                            if (output1 == IntPtr.Zero) throw new InvalidOperationException("This Windows version has no IDXGIOutput1 (needs Windows 8 or later)");
                        }
                        Release(ref output);
                        if (output1 != IntPtr.Zero) break;
                    }
                    Release(ref adapter);
                }
            }
            finally { Marshal.FreeHGlobal(desc); Release(ref factory); }
            if (output1 == IntPtr.Zero) throw new InvalidOperationException("No DXGI output named " + deviceName);
            Duplicate();
        }

        void Duplicate()
        {
            Release(ref dup);
            Check(Slot<DuplicateFn>(output1, 22)(output1, device, out dup), "DuplicateOutput");
        }

        // Returns a new bitmap of the current screen. When nothing changed since the last call, returns a copy of the last frame.
        public Bitmap Grab(int timeoutMs) { return Grab(timeoutMs, 0); }
        Bitmap Grab(int timeoutMs, int attempt)
        {
            IntPtr info = Marshal.AllocHGlobal(64), resource;
            try
            {
                int hr = Slot<AcquireFn>(dup, 8)(dup, (uint)timeoutMs, info, out resource);
                if (hr == WAIT_TIMEOUT && last != null) return (Bitmap)last.Clone();
                if ((hr == ACCESS_LOST || hr == WAIT_TIMEOUT) && attempt < 20) { if (hr == ACCESS_LOST) Duplicate(); return Grab(Math.Max(timeoutMs, 100), attempt + 1); }
                Check(hr, "AcquireNextFrame");
                try
                {
                    Guid iidTex = new Guid("6f15aaf2-d208-4e89-9ab4-489535d34f9c");
                    IntPtr tex; Check(Slot<QueryFn>(resource, 0)(resource, ref iidTex, out tex), "QueryInterface(ID3D11Texture2D)");
                    try
                    {
                        if (staging == IntPtr.Zero) MakeStaging(tex);
                        Slot<CopyResourceFn>(context, 47)(context, staging, tex);
                    }
                    finally { Release(ref tex); }
                }
                finally { Release(ref resource); Slot<ReleaseFrameFn>(dup, 14)(dup); }
                IntPtr mapped = Marshal.AllocHGlobal(16);
                try
                {
                    Check(Slot<MapFn>(context, 14)(context, staging, 0, 1 /*READ*/, 0, mapped), "Map");
                    IntPtr data = Marshal.ReadIntPtr(mapped); int pitch = Marshal.ReadInt32(mapped, IntPtr.Size);
                    var bmp = new Bitmap(Width, Height, PixelFormat.Format32bppRgb);
                    var bd = bmp.LockBits(new Rectangle(0, 0, Width, Height), ImageLockMode.WriteOnly, PixelFormat.Format32bppRgb);
                    var row = new byte[Width * 4];
                    for (int y = 0; y < Height; y++)
                    {
                        Marshal.Copy(IntPtr.Add(data, y * pitch), row, 0, row.Length);
                        Marshal.Copy(row, 0, IntPtr.Add(bd.Scan0, y * bd.Stride), row.Length);
                    }
                    bmp.UnlockBits(bd);
                    Slot<UnmapFn>(context, 15)(context, staging, 0);
                    if (last != null) last.Dispose();
                    last = (Bitmap)bmp.Clone();
                    return bmp;
                }
                finally { Marshal.FreeHGlobal(mapped); }
            }
            finally { Marshal.FreeHGlobal(info); }
        }

        void MakeStaging(IntPtr tex)
        {
            IntPtr d = Marshal.AllocHGlobal(44);
            try
            {
                Slot<TexDescFn>(tex, 10)(tex, d);              // D3D11_TEXTURE2D_DESC
                Marshal.WriteInt32(d, 8, 1);                    // MipLevels
                Marshal.WriteInt32(d, 12, 1);                   // ArraySize
                Marshal.WriteInt32(d, 28, 3);                   // Usage = STAGING
                Marshal.WriteInt32(d, 32, 0);                   // BindFlags
                Marshal.WriteInt32(d, 36, 0x20000);             // CPUAccessFlags = READ
                Marshal.WriteInt32(d, 40, 0);                   // MiscFlags
                Check(Slot<CreateTexFn>(device, 5)(device, d, IntPtr.Zero, out staging), "CreateTexture2D");
            }
            finally { Marshal.FreeHGlobal(d); }
        }

        public void Dispose()
        {
            Release(ref staging); Release(ref dup); Release(ref output1); Release(ref context); Release(ref device);
            if (last != null) { last.Dispose(); last = null; }
        }
    }
}
