using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
///using System.Threading.Tasks;
using OpenRTM_aist;
using System.Runtime.InteropServices;

namespace RTC
{
    using Manager_t = Int32;
    using Result_t = Int32;
    using RTC_t = Int32;
    using DataType_t = Int32;
    using Port_t = Int32;

    
    public class PortBase {

        const string rtmadapter_dll = "RTMAdapter";

        [DllImport(rtmadapter_dll, CallingConvention = CallingConvention.Cdecl)]
        protected static extern Result_t OutPort_write(Port_t p);

        [DllImport(rtmadapter_dll, CallingConvention = CallingConvention.Cdecl)]
        protected static extern Result_t InPort_read(Port_t p, out Int32 result);

        [DllImport(rtmadapter_dll, CallingConvention = CallingConvention.Cdecl)]
        protected static extern IntPtr Port_getBuffer();

        protected Port_t _port;
        protected string _name;

        public string getName() { return _name; }
        public Port_t d() { return _port; }

        public PortBase(string name, Int32 port)
        {
            _name = name;
            _port = port;
        }

        public static IntPtr getBuffer()
        {
            return Port_getBuffer();
        }
    }
    
    public class InPort<Type> : PortBase 
        where Type : DataTypeBase
    {
        private Type _t;

        public InPort(string name, Type typ) : base(name, typ.createInPort(name))
        {
            _t = typ;
        }

        public Int32 read()
        {
            int result;
            InPort_read(base.d(), out result);
            _t.down();
            return result;
        }
    }

    public class OutPort<Type> : PortBase 
        where Type : DataTypeBase
    {

        private Type _t;

        public OutPort(string name, Type typ) : base(name, typ.createOutPort(name))
        {
            _t = typ;
        }

        public Int32 write()
        {
            _t.up();
            OutPort_write(d());
            return 0;
        }
    }
}