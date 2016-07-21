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
    {{ a.name.replace('.', '_') }}
  {%- endif -%}
{%- endmacro -%}

{%- macro tile_arguments(dt, direction='in') -%}
  {% for a in dt.arguments %}{{ members(a, loop, direction=direction) }}{% endfor %}
{%- endmacro -%}

{%- macro sequence_setget(datatype, a) -%}
  DATAADAPTER_API Result_t {{ datatype.full_path.replace('::', '_') }}_{{ a.name.replace('.','_') }}_getLength(DataType_t d, uint32_t* size);
  
  DATAADAPTER_API Result_t {{ datatype.full_path.replace('::', '_') }}_{{ a.name.replace('.','_') }}_setLength(DataType_t d, uint32_t size);
  
  {%- if not a.primitive_sequence == 'True' -%}
    {%- if a.inner_type.find('sequence<char>') >= 0 %}
  DATAADAPTER_API Result_t {{ datatype.full_path.replace('::', '_') }}_{{ a.name.replace('.','_') }}_getLengthWithIndex(DataType_t d, uint32_t index, uint32_t* size);
  
  DATAADAPTER_API Result_t {{ datatype.full_path.replace('::', '_') }}_{{ a.name.replace('.','_') }}_setLengthWithIndex(DataType_t d, uint32_t index, uint32_t size);

  DATAADAPTER_API Result_t {{ datatype.full_path.replace('::', '_') }}_{{ a.name.replace('.','_') }}_setWithIndex(DataType_t d, uint32_t index, char* data, uint32_t size);

  DATAADAPTER_API Result_t {{ datatype.full_path.replace('::', '_') }}_{{ a.name.replace('.','_') }}_getWithIndex(DataType_t d, uint32_t index, char* data, uint32_t* size);
    {%- endif -%}
  {%- endif -%}
{%- endmacro -%}

#pragma once
#include "adapter_common.h"
#include "dataadapter_common.h"

#ifdef __cplusplus
extern "C" {
#endif

{%- for datatype in datatypes %}

  DATAADAPTER_API Result_t {{ datatype.full_path.replace('::', '_') }}_registerDataType(void* portBuffer);

  DATAADAPTER_API DataType_t {{ datatype.full_path.replace('::', '_') }}_create();
{% for a in datatype.arguments %}{% if a.type.find('sequence') >= 0 %}
  {{ sequence_setget(datatype, a) }}
{% endif %}{% endfor %}
  DATAADAPTER_API Result_t {{ datatype.full_path.replace('::', '_') }}_set(DataType_t d, {{ tile_arguments(datatype, direction='in') }});
  
  DATAADAPTER_API Result_t {{ datatype.full_path.replace('::', '_') }}_get(DataType_t d, {{ tile_arguments(datatype, direction='out') }});

  DATAADAPTER_API Port_t InPort_{{ datatype.full_path.replace('::', '_') }}_create(char* name, DataType_t d);

  DATAADAPTER_API Result_t InPort_{{ datatype.full_path.replace('::', '_') }}_isNew(Port_t port, int32_t* flag);

  DATAADAPTER_API Port_t OutPort_{{ datatype.full_path.replace('::', '_') }}_create(char* name, DataType_t d);

{%- endfor %}

#ifdef __cplusplus
}
#endif

