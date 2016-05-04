using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Runtime.InteropServices;

namespace RTC {
    using Manager_t = Int32;
    using Result_t = Int32;
    using RTC_t = Int32;
    using Port_t = Int32;

    public interface DataTypeBase
    {
        const string datatype_dll = "{{ filename }}";
    
        Port_t createOutPort(string name);
        Port_t createInPort(string name);
        bool InPortIsNew(Port_t port);

        void up();
        void down();
    }

}
