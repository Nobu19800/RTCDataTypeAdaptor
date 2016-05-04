/**
 * filename : {{ filename }}
 */


{% macro members(a, loop, direction='in') -%}
  {%- if a.type.find('sequence') >= 0 -%}
    {%- if a.primitive_sequence == 'True' -%}
      {%- if loop.index0 != 0 -%}, {% endif -%}	
      {{ a.inner_type }}* {{ a.name.replace('.','_') }}, uint32_t{%- if direction == 'out' -%}*{%- endif %} {{ a.name.replace('.','_') }}_size
    {%- else -%}
     
    {%- endif -%}
  {%- elif a.type == 'string' -%}
      {%- if loop.index0 != 0 -%}, {% endif -%}	
    char* {{ a.name.replace('.','_') }}
  {%- elif a.type == 'wstring' -%}
      {%- if loop.index0 != 0 -%}, {% endif -%}	
    uint16_t* {{ a.name.replace('.','_') }}
  {%- else -%}
    {%- if loop.index0 != 0 -%}, {% endif -%}	
    {{ a.type }}
    {%- if direction == 'out' -%}* {% else %} {% endif -%}
    {{ a.name.replace('.','_') }}
  {%- endif -%}
{%- endmacro -%}

{%- macro tile_arguments(dt, direction='in') -%}
  {% for a in dt.arguments %}{{ members(a, loop, direction=direction) }}{% endfor %}
{%- endmacro -%}


{%- macro string_setget(datatype, context, a) %}
Result_t {{ context }}_getLength(DataType_t d, uint32_t* size) {
  if (d < 0 || (uint32_t)d >= _data_{{ datatype.full_path.replace('::', '_') }}.size()) { return RESULT_INVALID_DATA; }
  *size = strlen((char*)_data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }});
  return RESULT_OK;  
}
{%- endmacro -%}

{%- macro wstring_setget(datatype, context, a) %}
Result_t {{ context }}_getLength(DataType_t d, uint32_t* size) {
  if (d < 0 || (uint32_t)d >= _data_{{ datatype.full_path.replace('::', '_') }}.size()) { return RESULT_INVALID_DATA; }
  *size = wcslen((wchar_t*)_data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }});
  return RESULT_OK;  
}
{%- endmacro -%}

{%- macro sequence_setget(datatype, context, a) %}

Result_t {{ context }}_getLength(DataType_t d, uint32_t* size) {
  if (d < 0 || (uint32_t)d >= _data_{{ datatype.full_path.replace('::', '_') }}.size()) { return RESULT_INVALID_DATA; }
    *size = _data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }}.length();
  return RESULT_OK;  
}
  
Result_t {{ context }}_setLength(DataType_t d, uint32_t size) {
  if (d < 0 || (uint32_t)d >= _data_{{ datatype.full_path.replace('::', '_') }}.size()) { return RESULT_INVALID_DATA; }
  _data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }}.length(size);
  return RESULT_OK;
}
  
  {%- if not a.primitive_sequence == 'True' -%}
    {%- if a.inner_type == 'string' %}
Result_t {{ context }}_setWithIndex(DataType_t d, uint32_t index, char* data) {
  if (d < 0 || (uint32_t)d >= _data_{{ datatype.full_path.replace('::', '_') }}.size()) { return RESULT_INVALID_DATA; }
  _data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }}[index] = CORBA::string_dup(data);  
  return RESULT_OK;
}

Result_t {{ context }}_getWithIndex(DataType_t d, uint32_t index, char* data) {
  if (d < 0 || (uint32_t)d >= _data_{{ datatype.full_path.replace('::', '_') }}.size()) { return RESULT_INVALID_DATA; }
  strcpy(data, (char*)_data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }}[index]);
  return RESULT_OK;
}
    {%- elif a.inner_type == 'wstring' %}
Result_t {{ context }}_setWithIndex(DataType_t d, uint32_t index, wchar_t* data) {
  if (d < 0 || (uint32_t)d >= _data_{{ datatype.full_path.replace('::', '_') }}.size()) { return RESULT_INVALID_DATA; }
  _data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }}[index] = CORBA::wstring_dup(data);  
  return RESULT_OK;
}

Result_t {{ context }}_getWithIndex(DataType_t d, uint32_t index, wchar_t* data) {
  if (d < 0 || (uint32_t)d >= _data_{{ datatype.full_path.replace('::', '_') }}.size()) { return RESULT_INVALID_DATA; }
  wcscpy(data, (wchar_t*)_data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }}[index]);
  return RESULT_OK;
}

    {%- elif a.inner_type.find('sequence') >= 0 -%}
Result_t {{ context }}_getLengthWithIndex(DataType_t d, uint32_t index, uint32_t* size) {
  if (d < 0 || (uint32_t)d >= _data_{{ datatype.full_path.replace('::', '_') }}.size()) { return RESULT_INVALID_DATA; }
  *size = _data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }}[index].length();
  return RESULT_OK;
}
  
Result_t {{ context }}_setLengthWithIndex(DataType_t d, uint32_t index, uint32_t size) {
  if (d < 0 || (uint32_t)d >= _data_{{ datatype.full_path.replace('::', '_') }}.size()) { return RESULT_INVALID_DATA; }
  _data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }}[index].length(size);
  return RESULT_OK;
}

Result_t {{ context }}_setWithIndex(DataType_t d, uint32_t index, char* data, uint32_t size) {
  if (d < 0 || (uint32_t)d >= _data_{{ datatype.full_path.replace('::', '_') }}.size()) { return RESULT_INVALID_DATA; }
  return RESULT_OK;
}

Result_t {{ context }}_getWithIndex(DataType_t d, uint32_t index, char* data, uint32_t* size) {
  if (d < 0 || (uint32_t)d >= _data_{{ datatype.full_path.replace('::', '_') }}.size()) { return RESULT_INVALID_DATA; }  
  return RESULT_OK;
}
    {%- endif -%}
  {%- endif -%}
{%- endmacro -%}

{%- macro member_utility(datatype) -%}
  {%- for a in datatype.arguments -%}
{% set context = datatype.full_path.replace('::', '_') + '_'+ a.name.replace('.','_')  %}
    {%- if a.type == 'string' %}
      {{ string_setget(datatype, context, a) }}     
    {%- elif a.type == 'wstring' %}
      {{ wstring_setget(datatype, context, a) }}     
    {% elif a.type.find('sequence') >= 0 %}
      {{ sequence_setget(datatype, context, a) }}     
    {% endif -%}
  {%- endfor -%}
{%- endmacro -%}



#include <vector>
#include <memory>
#include "adapter_common.h"
{% for idl in idls %}
#include "{{ idl.filename[:-4] }}.hh"
{% endfor %}
{% for idl in include_idls %}
#include "{{ idl.filename[:-4] }}.hh"
{% endfor %}
#include <rtm/Manager.h>
#include <rtm/DataInPort.h>
#include <rtm/DataOutPort.h>

static std::vector<std::shared_ptr<RTC::PortBase> >* __ports;

#define CHECK_PORT_ID(port) do {if(port<0 || (uint32_t)port>=__ports->size()){return RESULT_INVALID_PORT;} }while(false)

{% for datatype in datatypes %}
static std::vector<std::shared_ptr<{{ datatype.full_path }}> > _data_{{ datatype.full_path.replace('::', '_') }};
{%- endfor %}

{%- for datatype in datatypes %}


Result_t {{ datatype.full_path.replace('::', '_') }}_registerDataType(void* portBuffer) {
  __ports = static_cast<std::vector<std::shared_ptr<RTC::PortBase> >* >(portBuffer);
  return RESULT_OK;
}

DataType_t {{ datatype.full_path.replace('::', '_') }}_create() {
  _data_{{ datatype.full_path.replace('::', '_') }}.push_back(std::shared_ptr<{{ datatype.full_path }}>(new {{ datatype.full_path }}()));
  return _data_{{ datatype.full_path.replace('::', '_') }}.size() -1;
}


{{- member_utility(datatype) }}

Result_t {{ datatype.full_path.replace('::', '_') }}_set(DataType_t d, {{ tile_arguments(datatype, direction='in') }}) {
  if (d < 0 || (uint32_t)d >= _data_{{ datatype.full_path.replace('::', '_') }}.size()) { return RESULT_INVALID_DATA; }
{%- for a in datatype.arguments -%}
  {%- if a.type == 'string' %}
  _data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }} = CORBA::string_dup({{ a.name.replace('.', '_') }});
  {%- elif a.type == 'wstring' %}
  _data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }} = CORBA::wstring_dup((wchar_t*){{ a.name.replace('.', '_') }});
  {%- elif a.type.find('sequence') < 0 %}
  _data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }} = {{ a.name.replace('.','_') }};
  {%- else -%}
    {%- if a.primitive_sequence == 'True' %}
  memcpy(&(_data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }}[0]), {{ a.name.replace('.','_') }}, {{ a.name.replace('.','_') }}_size * sizeof({{ a.inner_type }}));
    {%- endif -%}
  {%- endif -%}
{%- endfor %}
  return RESULT_OK;
}

Result_t {{ datatype.full_path.replace('::', '_') }}_get(DataType_t d, {{ tile_arguments(datatype, direction='out') }}) {
  if (d < 0 || (uint32_t)d >= _data_{{ datatype.full_path.replace('::', '_') }}.size()) { return RESULT_INVALID_DATA; }
{% for a in datatype.arguments %}
  {%- if a.type == 'string' %}
  strcpy({{ a.name.replace('.','_') }}, (const char*)(_data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }}));
  {%- elif a.type == 'wstring' %}
  wcscpy((wchar_t*){{ a.name.replace('.','_') }}, (const wchar_t*)(_data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }}));
  {%- elif a.type.find('sequence') < 0 %}
  *{{ a.name.replace('.','_') }} = _data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }};
  {%- else -%}
    {%- if a.primitive_sequence == 'True' %}
    if (*{{ a.name.replace('.','_') }}_size < _data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }}.length()) {
      return RESULT_ERROR;
    }
    *{{ a.name.replace('.','_') }}_size = _data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }}.length();
  memcpy({{ a.name.replace('.','_') }}, &(_data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }}[0]), _data_{{ datatype.full_path.replace('::', '_') }}[d]->{{ a.name }}.length() * sizeof({{ a.inner_type }}));
    {%- endif -%}
  {% endif %}
{%- endfor %}
  return RESULT_OK;
}


Port_t InPort_{{ datatype.full_path.replace('::', '_') }}_create(char* name, DataType_t d) {
  if (d < 0 || (uint32_t)d >= _data_{{ datatype.full_path.replace('::', '_') }}.size()) { return RESULT_INVALID_DATA; }
  __ports->push_back(std::shared_ptr<RTC::PortBase>(new RTC::InPort<{{ datatype.full_path }}>(name, *(_data_{{ datatype.full_path.replace('::', '_') }}[d]))));
  return __ports->size() - 1;
}

Port_t OutPort_{{ datatype.full_path.replace('::', '_') }}_create(char* name, DataType_t d) {
  if (d < 0 || (uint32_t)d >= _data_{{ datatype.full_path.replace('::', '_') }}.size()) { return RESULT_INVALID_DATA; }
  __ports->push_back(std::shared_ptr<RTC::PortBase>(new RTC::OutPort<{{ datatype.full_path }}>(name, *(_data_{{ datatype.full_path.replace('::', '_') }}[d]))));
  return __ports->size() - 1;
}

Result_t InPort_{{ datatype.full_path.replace('::', '_') }}_isNew(Port_t port, int32_t* flag) {
  CHECK_PORT_ID(port);
  std::shared_ptr<RTC::InPort<{{ datatype.full_path }}> > inport = std::dynamic_pointer_cast<RTC::InPort<{{ datatype.full_path }}> >((*__ports)[port]);
  if (inport == nullptr) { return RESULT_INVALID_PORT; }

  *flag = inport->isNew() ? 1 : 0;
  return RESULT_OK;
}


{%- endfor -%}