{% macro members(a, loop, direction='in') -%}

   {%- if a.type.find('sequence') >= 0 -%}
     {%- if a.primitive_sequence == 'True' -%}
     {%- if loop.index0 != 0 -%}, {% endif -%}	
     {{ a.inner_type }}* {{ a.name }}, uint32_t{%- if direction == 'out' -%}*{%- endif %} size
     {%- else -%}
     
     {%- endif -%}
   {%- else -%}
     {%- if loop.index0 != 0 -%}, {% endif -%}	
     {{ a.type }}
     {%- if direction == 'out' -%}* {% else %} {% endif -%}
     {{ a.name }}
   {%- endif -%}
{%- endmacro -%}

{%- macro tile_arguments(dt, direction='in') -%}
  {% for a in dt.arguments %}{{ members(a, loop, direction=direction) }}{% endfor %}
{%- endmacro -%}

{%- macro sequence_setget(datatype, a) -%}
  ADAPTER_API Result_t {{ datatype.full_path }}_{{ a.name }}_getLength(DataType_t d, uint32_t* size);
  
  ADAPTER_API Result_t {{ datatype.full_path }}_{{ a.name }}_setLength(DataType_t d, uint32_t size);
  
  {%- if not a.primitive_sequence == 'True' -%}
    {%- if a.inner_type.find('sequence<char>') >= 0 %}
  ADAPTER_API Result_t {{ datatype.full_path }}_{{ a.name }}_getLengthWithIndex(DataType_t d, uint32_t index, uint32_t* size);
  
  ADAPTER_API Result_t {{ datatype.full_path }}_{{ a.name }}_setLengthWithIndex(DataType_t d, uint32_t index, uint32_t size);

  ADAPTER_API Result_t {{ datatype.full_path }}_{{ a.name }}_setWithIndex(DataType_t d, uint32_t index, char* data, uint32_t size);

  ADAPTER_API Result_t {{ datatype.full_path }}_{{ a.name }}_getWithIndex(DataType_t d, uint32_t index, char* data, uint32_t* size);
    {%- endif -%}
  {%- endif -%}
{%- endmacro -%}

#pragma once
#include "adapter_common.h"

#ifdef __cplusplus
extern "C" {
#endif

  ADAPTER_API Result_t {{ datatype.full_path }}_registerDataType(void* portBuffer);

  ADAPTER_API DataType_t {{ datatype.full_path }}_create();
{% for a in datatype.arguments %}{% if a.type.find('sequence') >= 0 %}
  {{ sequence_setget(datatype, a) }}
{% endif %}{% endfor %}
  ADAPTER_API Result_t {{ datatype.full_path }}_set(DataType_t d, {{ tile_arguments(datatype, direction='in') }});
  
  ADAPTER_API Result_t {{ datatype.full_path }}_get(DataType_t d, {{ tile_arguments(datatype, direction='out') }});

  ADAPTER_API Port_t InPort_{{ datatype.full_path }}_create(char* name, DataType_t d);

  ADAPTER_API Result_t InPort_{{ datatype.full_path }}_isNew(Port_t port, int32_t* flag);

  ADAPTER_API Port_t OutPort_{{ datatype.full_path }}_create(char* name, DataType_t d);


#ifdef __cplusplus
}
#endif

