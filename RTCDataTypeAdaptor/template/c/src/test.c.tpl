#include <stdio.h>

#include "RTMAdapter-1.0/manager_adapter.h"
#include "RTMAdapter-1.0/coil_adapter.h"
{% for idl in idls %}
#include "{{ idl.filename[:-4] }}.h"
{% endfor %}


RTC_t rtc;


// -------------- RTC Functions -------------------
int initialize(RTC_t rtc);
int on_activated(int ec_id);
int on_deactivated(int ec_id);
int on_execute(int ec_id);

void my_module_init(Manager_t m) {
        Manager_RTMAdapter_init(m);
        if (rtc = Manager_createComponent(m, "RTMAdapter") == RESULT_INVALID_RTC) {
                printf("#Error. Invalid RTC ID.\n");
                return;
        }

	initialize(rtc);

	RTC_onActivated_listen(rtc, on_activated);
	RTC_onDeactivated_listen(rtc, on_deactivated);
	RTC_onExecute_listen(rtc, on_execute);
}


int main(int argc, char* argv[]) {
	Manager_t m = Manager_initManager(argc, argv);
	Manager_init(m, argc, argv);
	Manager_setModuleInitProc(m, my_module_init);
	Manager_activateManager(m);
	Manager_runManager(m, 0);

	return 0;
}


//------------------------ RTC Code ---------------------------


{% for datatype in datatypes %}
DataType_t _d_in_{{ datatype.full_path.replace('::', '_') }}, _d_out_{{ datatype.full_path.replace('::', '_') }};
Port_t _in_{{ datatype.full_path.replace('::', '_') }}In, _out_{{ datatype.full_path.replace('::', '_') }}Out;

{% endfor %}

/**
 * Initialize RTC.
 * on_initialize can not be captured in current version.
 * Please initialize RTC in my_module_init proc.
 */
int initialize(RTC_t rtc) {
{% for datatype in datatypes %}
        _d_in_{{ datatype.full_path.replace('::', '_') }} = {{ datatype.full_path.replace('::', '_') }}_create();
        _in_{{ datatype.full_path.replace('::', '_') }}In = InPort_{{ datatype.full_path.replace('::', '_') }}_create("{{ datatype.full_path.replace('::', '_') }}_in", _d_in_{{ datatype.full_path.replace('::', '_') }});
        if (RTC_addInPort(rtc, "{{ datatype.full_path.replace('::', '_') }}_in", _in_{{ datatype.full_path.replace('::', '_') }}In) < 0) {
                return -1;
        }

        _d_out_{{ datatype.full_path.replace('::', '_') }} = {{ datatype.full_path.replace('::', '_') }}_create();
        _out_{{ datatype.full_path.replace('::', '_') }}Out = OutPort_{{ datatype.full_path.replace('::', '_') }}_create("{{ datatype.full_path.replace('::', '_') }}_out", _d_out_{{ datatype.full_path.replace('::', '_') }});
        if (RTC_addOutPort(rtc, "{{ datatype.full_path.replace('::', '_') }}_out", _out_{{ datatype.full_path.replace('::', '_') }}Out) < 0) {
                return -1;
        }
{% endfor %}
        return 0;
}

int on_activated(int ec_id) {
        printf("on_activated called.\n");
}

int on_deactivated(int ec_id) {
        printf("on_deactivated called.\n");
}

int on_execute(int ec_id) {
	int32_t flag;
{% for datatype in datatypes %}
	InPort_{{ datatype.full_path.replace('::', '_') }}_isNew(_in_{{ datatype.full_path.replace('::', '_') }}In, &flag);
	if (flag) {
		InPort_read(_in_{{ datatype.full_path.replace('::', '_') }}In, &flag);
	}

	OutPort_write(_out_{{ datatype.full_path.replace('::', '_') }}Out);
{% endfor %}
	return 0;
}
