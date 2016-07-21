{# Type Conversion Test #}
{%- macro typecomp(t) -%}
  {%- if t == 'char' -%} SByte
  {%- elif t == 'boolean' -%} bool
  {%- elif t == 'octet' -%} Byte
  {%- elif t == 'wchar' -%} Char
  {%- elif t == 'short' -%} Int16
  {%- elif t == 'long' -%}  Int32
  {%- elif t == 'double' -%} double
  {%- elif t == 'float' -%} float
  {%- elif t == 'unsigned short' -%} UInt16
  {%- elif t == 'unsigned long' -%} UInt32
  {%- elif t == 'string' -%} String
  {%- elif t == 'wstring' -%} String
  {%- elif t.startswith('sequence') -%}
    {%- set dn = t[9:-1] -%}
    List<{{ typecomp(dn) }}>
  {%- else -%} {{ t }}
  {%- endif -%}
{%- endmacro -%}

{%- macro ctypecomp(t) -%}
  {%- if t == 'char' -%} char
  {%- elif t == 'int32_t' -%} Int32
  {%- elif t == 'uint32_t' -%} UInt32
  {%- elif t == 'int16_t' -%} Int16
  {%- elif t == 'uint16_t' -%} UInt16
  {%- elif t == 'int8_t' -%} SByte
  {%- elif t == 'uint8_t' -%} Byte
  {%- elif t == 'double' -%} double
  {%- elif t == 'float' -%} float
  {%- endif -%}
{%- endmacro -%}

{%- macro default(t) -%}
  {%- if t == 'char' -%} 0
  {%- elif t == 'boolean' -%} false
  {%- elif t == 'octet' -%} 0
  {%- elif t == 'wchar' -%} '\x0000'
  {%- elif t == 'short' -%} 0
  {%- elif t == 'long' -%}  0
  {%- elif t == 'double' -%} 0.0
  {%- elif t == 'float' -%} 0.0F
  {%- elif t == 'unsigned short' -%} 0
  {%- elif t == 'unsigned long' -%} 0
  {%- elif t == 'string' -%} ""
  {%- elif t == 'wstring' -%} ""
  {%- elif t.startswith('sequence') -%}
    {%- set dn = t[9:-1] -%}
    new List<{{ typecomp(dn) }}>()
  {%- else -%} new {{ t }}()
  {%- endif -%}
{%- endmacro -%}

{% macro members(a, loop, direction='in') -%}
  {%- if a.type.find('sequence') >= 0 -%}
    {%- if a.primitive_sequence == 'True' -%}
      {%- if loop.index0 != 0 -%}, {% endif -%}
        {%- if direction == 'out' -%}
      out {% else -%} ref {% endif -%} {{ ctypecomp(a.inner_type) }}[] {{ a.name.replace('.','_') }}, {%- if direction == 'out' %} out {% endif %} UInt32 {{ a.name.replace('.','_') }}_size
    {%- else -%}
     
    {%- endif -%}
  {%- elif a.type == 'string' -%}
      {%- if loop.index0 != 0 -%}, {% endif -%}	
  
    {%- if direction == 'out' -%}out {% endif %} string {{ a.name.replace('.','_') }}
  {%- elif a.type == 'wstring' -%}
      {%- if loop.index0 != 0 -%}, {% endif -%}	
    {%- if direction == 'out' -%}out {% endif %} string {{ a.name.replace('.','_') }}
  {%- else -%}
    {%- if loop.index0 != 0 -%}, {% endif -%}	
    {%- if direction == 'out' -%} out {% else %} {% endif -%}
    {{ ctypecomp(a.type) }} {{ a.name.replace('.','_') }}
  {%- endif -%}
{%- endmacro -%}

{%- macro tile_arguments(dt, direction='in') -%}
  {% for a in dt.arguments %}{{ members(a, loop, direction=direction) }}{% endfor %}
{%- endmacro -%}

{%- macro calling_members(d, a, loop, direction='in') -%}

  {%- set found=[] -%}
  {%- for m in d.members -%} {%- if m.name == a.name -%}
    {%- do found.append(1) -%}
    {%- if m.type.name == 'wchar' -%}
      {%- if direction=='out' -%} 
 out {{ a.name }}_
      {%- else -%}
 (Int16)(UInt16){{ a.name }}
      {%- endif -%}
    {%- elif m.type.name == 'boolean' -%}
      {%- if direction=='out' -%} 
 out {{ a.name }}_
      {%- else -%}
 {{ a.name }} ? (Byte)1 : (Byte)0       
      {%- endif -%}
    {%- elif m.type.name.find('sequence') >= 0 -%}
      {%- if direction=='in' -%}
ref {{ a.name.replace('.','_') }}_, (UInt32){{ a.name }}.Count
      {%- else -%}
out {{ a.name.replace('.','_') }}_, out len_{{ a.name.replace('.','_') }}
      {%- endif -%}
    {%- else -%}
      {%- if direction=='out' -%} 
 out {{ a.name }}
      {%- else -%}
 {{ a.name }}
      {%- endif -%}
    {%- endif %}
  {%- endif -%}{%- endfor -%}
  {%- if found|length == 0 -%}
    {%- if direction=='out' -%} 
out {{ a.name }}
    {%- else -%}
      {%- if a.type.find('sequence') >= 0 -%}
ref {{ a.name.replace('.','_') }}_, (UInt32){{ a.name }}.Count
      {%- else -%}
{{ a.name }}
      {%- endif -%}
    {%- endif -%}
  {%- endif -%}
{%- if loop.index != loop.length -%}, {% endif -%}

{%- endmacro -%}

{%- macro tile_calling_arguments(d, direction='in') -%}
  {%- for a in d.arguments -%}{{ calling_members(d, a, loop, direction) }}{%- endfor -%}
{%- endmacro -%}

{#- FOR SEQUENCE -#}

{%- macro sequence_setget(datatype, context, a) %}
     [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
     private static extern Result_t {{ context }}_getLength(DataType_t d, out UInt32 size);

     [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
     private static extern Result_t {{ context }}_setLength(DataType_t d, UInt32 size);

  {%- if not a.primitive_sequence == 'True' -%}
    {%- if a.inner_type == 'string' %}
     [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
     private static extern Result_t {{ context }}_setWithIndex(DataType_t d, UInt32 index, string data);

     [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
     private static extern Result_t {{ context }}_getWithIndex(DataType_t d, UInt32 index, out string data);

    {%- elif a.inner_type == 'wstring' %}
     [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
     private static extern Result_t {{ context }}_setWithIndex(DataType_t d, UInt32 index, string data);

     [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
     private static extern Result_t {{ context }}_getWithIndex(DataType_t d, UInt32 index, out string data);

   {%- elif a.inner_type.find('sequence') >= 0 -%}
     [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
     private static extern Result_t {{ context }}_getLengthWithIndex(DataType_t d, UInt32 index, out UInt32 size);

     [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
     private static extern Result_t {{ context }}_setLengthWithIndex(DataType_t d, UInt32 index, UInt32 size);

     [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
     private static extern Result_t {{ context }}_setWithIndex(DataType_t d, UInt32 index, string data, UInt32 size);

     [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
     private static extern Result_t {{ context }}_getWithIndex(DataType_t d, UInt32 index, out string data, out UInt32 size);
    {%- endif -%}
  {%- endif -%}
{%- endmacro -%}

{%- macro member_utility(datatype) -%}
  {%- for a in datatype.arguments -%}
{% set context = datatype.full_path.replace('::', '_') + '_'+ a.name.replace('.','_') %}
    {% if a.type.find('sequence') >= 0 %}
      {{ sequence_setget(datatype, context, a) }}
    {% endif -%}
  {%- endfor -%}
{%- endmacro -%}

{# FOR SEQUENCE END #}


{%- macro parse_datatype(d) -%}
  {%- set dn = d.full_path.replace('::','_') %}

  public class {{ d.name }} : RTC.DataTypeBase
  {
     protected const String datatype_dll = {{ filename }}Base.datatype_dll;

     [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
     private static extern Result_t {{ dn }}_registerDataType(IntPtr portBuffer);

     [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
     private static extern DataType_t {{ dn }}_create();

     [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
     private static extern Port_t InPort_{{ dn }}_create(string name, DataType_t d);

     [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
     private static extern Result_t InPort_{{ dn }}_isNew(Port_t port, out Int32 flag);

     [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
     private static extern Port_t OutPort_{{ dn }}_create(string name, DataType_t d);

     [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
     private static extern Result_t {{ dn }}_set(DataType_t d, {{ tile_arguments(d, direction='in') }});

     [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
     private static extern Result_t {{ dn }}_get(DataType_t d, {{ tile_arguments(d, direction='out') }});

  {{ member_utility(d) }}

  {% for m in d.members %}
    public {{ typecomp(m.type.name) }} {{ m.name }};
  {% endfor %}

    /// Default Constructor
    public {{ d.name }}() {
  {%- for m in d.members %}
      {{ m.name }} = {{ default( m.type.name ) }};
  {%- endfor %}
    }


    static void register()
    {
      if ({{ dn }}_registerDataType(RTC.PortBase.getBuffer()) < 0)
      {
         // Failed.
      }
    }

    public void up()
    {
  {% for a in d.arguments -%}
    {%- if a.type.find('sequence') >= 0 -%}
      {%- if a.primitive_sequence == 'True' %}
        {{ dn }}_{{ a.name.replace('.','_') }}_setLength(_d, (UInt32){{ a.name }}.Count);

        {%- if a.inner_truetype == 'wchar' %}
        Int16[] {{ a.name.replace('.', '_') }}_ = new Int16[{{a.name }}.Count];
        for(int i = 0;i < {{ a.name }}.Count;i++) {
          {{ a.name.replace('.','_') }}_[i] = (Int16)(UInt16){{ a.name }}[i];
        }
        {%- elif a.inner_truetype == 'boolean' %}
        Byte[] {{ a.name.replace('.','_') }}_ = new Byte[{{ a.name }}.Count];
        for(int i = 0;i < {{ a.name }}.Count;i++) {
          {{ a.name.replace('.','_') }}_[i] = {{ a.name }}[i] ? (Byte)1 : (Byte)0;
        }
        {%- else -%}
        {{ ctypecomp(a.inner_type) }}[] {{ a.name.replace('.', '_') }}_ = {{ a.name }}.ToArray();
        {%- endif -%}
      {%- endif -%}
    {%- endif -%}
  {%- endfor %}
      {{ dn }}_set(_d, {{ tile_calling_arguments(d, direction='in') }});
    }

    public void down()
    {
  {% for m in d.members -%}
    {% if m.type.name == 'wchar' -%} Int16 {{ m.name }}_; 
    {% elif m.type.name == 'boolean' -%} Byte {{ m.name }}_;
    {% endif -%}
  {%- endfor %}

  {% for a in d.arguments -%}
    {%- if a.type.find('sequence') >= 0 -%}
      {%- if a.primitive_sequence == 'True' %}
        UInt32 len_{{ a.name.replace('.','_') }};
        {{ dn }}_{{ a.name.replace('.','_') }}_getLength(_d, out len_{{ a.name.replace('.','_') }});
        {{ ctypecomp(a.inner_type) }}[] {{ a.name.replace('.', '_') }}_ = new {{ ctypecomp(a.inner_type) }}[len_{{ a.name.replace('.','_') }}];
      {% endif -%}
    {%- endif -%}
  {%- endfor %}

      {{ dn }}_get(_d, {{ tile_calling_arguments(d, direction='out') }});

  {% for m in d.members -%}
    {% if m.type.name == 'wchar' -%} {{ m.name }} = (Char)(UInt16) {{ m.name }}_; 
    {% elif m.type.name == 'boolean' -%} {{ m.name }} = {{ m.name }}_ == 0 ? false : true;
    {% endif -%}
  {%- endfor %}


  {% for a in d.arguments -%}
    {%- if a.type.find('sequence') >= 0 -%}
      {%- if a.primitive_sequence == 'True' %}
        {%- if a.inner_truetype == 'wchar' -%}
       {{ a.name }}.Clear();
       for(int i = 0;i < {{ a.name.replace('.','_') }}_.Length;i++) {
         {{ a.name }}.Add((Char)(UInt16){{ a.name.replace('.','_') }}_[i]);
       }

        {%- elif a.inner_truetype == 'boolean' -%}
       {{ a.name }}.Clear();
       for(int i = 0;i < {{ a.name.replace('.','_') }}_.Length;i++) {
         {{ a.name }}.Add({{ a.name.replace('.','_') }}_[i] == 0 ? false : true);
       }

        {%- else -%}
       {{ a.name }}.Clear();
       {{ a.name }}.AddRange( {{ a.name.replace('.','_') }}_ );
        {%- endif -%}
      {%- endif -%}
    {%- endif -%}
  {%- endfor %}

    }

    private DataType_t _d;

    public Port_t createOutPort(string name)
    {
        register();
        _d = {{ dn }}_create();
        return OutPort_{{ dn }}_create(name, _d);
     }

     public Port_t createInPort(string name)
     {
        register();
        _d = {{ dn }}_create();
        return InPort_{{ dn }}_create(name, _d);
     }

     public bool InPortIsNew(Port_t port)
     {
        int flag;
        if (InPort_{{ dn }}_isNew(port, out flag) < 0)
        {
          //
        }

        return flag != 0;
     }

  }

{%- endmacro -%}


{%- macro parse_module(mtree) -%}
  {%- set m = mtree.module -%}
  {%- set ds = mtree.datatypes %}

internal class {{ filename }}Base {
  public static String datatype_dll = "{{ filename }}.dll";
}

namespace {{ m.name }} {
  
  {% for d in ds %}
  {{ parse_datatype(d) }}

  {%- endfor %}

}
 

{%- endmacro -%}



using Manager_t= System.Int32;
using Result_t = System.Int32;
using RTC_t    = System.Int32;
using Port_t   = System.Int32;
using DataType_t = System.Int32;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
///using System.Threading.Tasks;

using System.Runtime.InteropServices;


{%- for d in module_tree.datatypes %}
  {{ parse_datatype(d) }}
{%- endfor -%}

{%- for c in module_tree.children -%}
  {{ parse_module(c) }}
{%- endfor -%}

 