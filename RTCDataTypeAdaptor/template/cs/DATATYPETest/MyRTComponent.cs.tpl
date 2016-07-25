using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using RTC;
using OpenRTM_aist;

namespace {{ filename }}CSTest
{

    using Manager_t = Int32;
    using Result_t = Int32;
    using RTC_t = Int32;
    using Port_t = Int32;


    class MyRTComponent : RTComponent
    {

        //RTC.TimedLong _out;
        //RTC.OutPort<RTC.TimedLong> _outOut;

        //RTC.TimedLong _in;
        //RTC.InPort<RTC.TimedLong> _inIn;


        static Dictionary<string, string> specs = new Dictionary<string, string>()
        {
            {"implementation_id",  "MyRTComponent"},
            {"type_name",  "MyRTComponent"},
        };

        public MyRTComponent(RTC_t rtc)
            : base(rtc)
        {
            //_out = new RTC.TimedLong();
            //_outOut = new RTC.OutPort<RTC.TimedLong>("out", _out);

            //_in = new RTC.TimedLong();
            //_inIn = new RTC.InPort<RTC.TimedLong>("in", _in);
        }

        public override int onInitialize(int ec_id)
        {
            System.Console.Write("onInitialize called.\n");
            //addOutPort(_outOut);
            //addInPort(_inIn);
            return 0;
        }

        public override int onActivated(int ec_id)
        {
            System.Console.Write("onActivated called.\n");
            return 0;
        }

        public override int onDeactivated(int ec_id)
        {
            System.Console.Write("onDeactivated called.\n");
            return 0;
        }

        public override int onExecute(int ec_id)
        {
            System.Console.Write("onExecute called.\n");

            //if (_inIn.isNew())
            //{
            //    _inIn.read();
            //
            //    System.Console.WriteLine("Data is {0}", _in.data);
            //}
            
            //_out.data = 1234;
            //_outOut.write();
            return 0;
        }

        public override int onError(int ec_id)
        {

            return 0;
        }

        public override int onReset(int ec_id)
        {

            return 0;
        }

        public override int onAborting(int ec_id)
        {

            return 0;
        }

        static RTComponent createMyRTComponent(RTC_t rtc)
        {
            return new MyRTComponent(rtc);
        }

        public static void MyRTComponent_init(Manager m)
        {
            m.RTMAdapter_init(specs, createMyRTComponent);
        }
    }
}
