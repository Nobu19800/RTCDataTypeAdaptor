{% macro members(a, loop, direction='in') -%}
   {%- if a.type.find('sequence') >= 0 -%}
     {%- if a.primitive_sequence == 'True' -%}
     {%- if loop.index0 != 0 -%}, {% endif -%}	
     {{ a.inner_type }}* {{ a.name.replace('.','_') }}, uint32_t{%- if direction == 'out' -%}*{%- endif %} size
     {%- else -%}
     
     {%- endif -%}
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

{%- macro sequence_setget(datatype, a) -%}
ADAPTER_API Result_t {{ datatype.full_path }}_{{ a.name.replace('.','_') }}_getLength(DataType_t d, uint32_t* size) {
  if (d < 0 || d >= _data.size()) { return RESULT_INVALID_DATA; }
    *size = _data[d]->{{ a.name }}.length();
  return OK;    
}
  
ADAPTER_API Result_t {{ datatype.full_path }}_{{ a.name.replace('.','_') }}_setLength(DataType_t d, uint32_t size) {
  if (d < 0 || d >= _data.size()) { return RESULT_INVALID_DATA; }
  _data[d]->{{ a.name }}.length(size);
  return OK;
}
  
  {%- if not a.primitive_sequence == 'True' -%}
    {%- if a.inner_type.find('sequence<char>') >= 0 %}
ADAPTER_API Result_t {{ datatype.full_path }}_{{ a.name.replace('.','_') }}_getLengthWithIndex(DataType_t d, uint32_t index, uint32_t* size) {
  if (d < 0 || d >= _data.size()) { return RESULT_INVALID_DATA; }
     *size = _data[d]->{{ a.name }}[index].length();
  return OK;
}
  
ADAPTER_API Result_t {{ datatype.full_path }}_{{ a.name.replace('.','_') }}_setLengthWithIndex(DataType_t d, uint32_t index, uint32_t size) {
  if (d < 0 || d >= _data.size()) { return RESULT_INVALID_DATA; }
    _data[d]->{{ a.name }}[index].length(size);
  return OK;
}

ADAPTER_API Result_t {{ datatype.full_path }}_{{ a.name.replace('.','_') }}_setWithIndex(DataType_t d, uint32_t index, char* data, uint32_t size) {
  if (d < 0 || d >= _data.size()) { return RESULT_INVALID_DATA; }
  
  return OK;
}

  ADAPTER_API Result_t {{ datatype.full_path }}_{{ a.name.replace('.','_') }}_getWithIndex(DataType_t d, uint32_t index, char* data, uint32_t* size) {
  if (d < 0 || d >= _data.size()) { return RESULT_INVALID_DATA; }  
  return OK;
}
    {%- endif -%}
  {%- endif -%}
{%- endmacro -%}

#include <vector>
#include <memory>
{% for idl in idls %}
#include "{{ idl.filename[:-4] }}.hh"
{% endfor %}
{% for idl in include_idls %}
#include "{{ idl.filename[:-4] }}.hh"
{% endfor %}
#include <rtm/Manager.h>
#include <rtm/DataInPort.h>
#include <rtm/DataOutPort.h>

#include "{{ datatype.name }}.h"

static std::vector<std::shared_ptr<RTC::{{ datatype.full_path }}> > _data;
static std::vector<std::shared_ptr<RTC::PortBase> >* __ports;

#define CHECK_PORT_ID(port) do {if(port<0 || port>=__ports->size()){return RESULT_INVALID_PORT;} }while(false)


Result_t {{ datatype.full_path }}_registerDataType(void* portBuffer) {
  __ports = static_cast<std::vector<std::shared_ptr<RTC::PortBase> >* >(portBuffer);
  return RESULT_OK;
}

DataType_t {{ datatype.full_path }}_create() {
  _data.push_back(std::shared_ptr<RTC::{{ datatype.full_path }}>(new RTC::{{ datatype.full_path }}()));
  return _data.size() -1;
}

{% for a in datatype.arguments %}{% if a.type.find('sequence') >= 0 %}
  {{ sequence_setget(datatype, a) }}
{% endif %}{% endfor %}

Result_t {{ datatype.full_path }}_set(DataType_t d, {{ tile_arguments(datatype, direction='in') }}) {
  if (d < 0 || d >= _data.size()) { return RESULT_INVALID_DATA; }
{% for a in datatype.arguments %}
  {% if a.type.find('sequence') < 0 %}
  _data[d]->{{ a.name }} = {{ a.name.replace('.','_') }};
  {%- else -%}
    {%- if a.primitive_sequence == 'True' %}
  memcpy(&(_data[d]->{{ a.name }}[0]), {{ a.name.replace('.','_') }}, size * sizeof({{ a.inner_type }}));
    {%- endif -%}
  {%- endif -%}
{%- endfor %}
  return OK;
}

Result_t {{ datatype.full_path }}_get(DataType_t d, {{ tile_arguments(datatype, direction='out') }}) {
  if (d < 0 || d >= _data.size()) { return RESULT_INVALID_DATA; }
{% for a in datatype.arguments %}
  *{{ a.name.replace('.','_') }} = _data[d]->{{ a.name }};
{%- endfor %}
  return OK;
}


Port_t InPort_{{ datatype.full_path }}_create(char* name, DataType_t d) {
  if (d < 0 || d >= _data.size()) { return RESULT_INVALID_DATA; }
  __ports->push_back(std::shared_ptr<RTC::PortBase>(new RTC::InPort<RTC::{{ datatype.full_path }}>(name, *(_data[d]))));
  return __ports->size() - 1;
}

Port_t OutPort_{{ datatype.full_path }}_create(char* name, DataType_t d) {
  if (d < 0 || d >= _data.size()) { return RESULT_INVALID_DATA; }
  __ports->push_back(std::shared_ptr<RTC::PortBase>(new RTC::OutPort<RTC::{{ datatype.full_path }}>(name, *(_data[d]))));
  return __ports->size() - 1;
}

Result_t InPort_{{ datatype.full_path }}_isNew(Port_t port, int32_t* flag) {
  CHECK_PORT_ID(port);
  std::shared_ptr<RTC::InPort<RTC::{{ datatype.full_path }}> > inport = std::dynamic_pointer_cast<RTC::InPort<RTC::{{ datatype.full_path }}> >((*__ports)[port]);
  if (inport == nullptr) { return RESULT_INVALID_PORT; }

  *flag = inport->isNew() ? 1 : 0;
  return RESULT_OK;
}
