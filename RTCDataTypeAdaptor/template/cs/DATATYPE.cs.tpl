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
      {{ a.inner_type }}* {{ a.name.replace('.','_') }}, UInt32{%- if direction == 'out' -%}*{%- endif %} {{ a.name.replace('.','_') }}_size
    {%- else -%}
     
    {%- endif -%}
  {%- elif a.type == 'string' -%}
      {%- if loop.index0 != 0 -%}, {% endif -%}	
    char* {{ a.name.replace('.','_') }}
  {%- elif a.type == 'wstring' -%}
      {%- if loop.index0 != 0 -%}, {% endif -%}	
    UInt16* {{ a.name.replace('.','_') }}
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
    {%- if m.type.name == 'wchar' -%} (Int16)(UInt16){{ a.name }} 
    {%- elif m.type.name == 'boolean' -%} {{ a.name }} ? (Byte)1 : (Byte)0 
    {%- else -%}{{ a.name }}{%- endif %}
  {%- endif -%}{%- endfor -%}
  {%- if found|length == 0 -%}
{{ a.name }}
  {%- endif -%}
{%- if loop.index != loop.length -%}, {% endif -%}

{%- endmacro -%}

{%- macro tile_calling_arguments(d, direction='in') -%}
  {%- for a in d.arguments -%}{{ calling_members(d, a, loop, direction) }}{%- endfor -%}
{%- endmacro -%}

{%- macro parse_datatype(d) -%}
  {%- set dn = d.full_path.replace('::','_') %}

  public class {{ d.name }} : {{ filename }}Base
  {
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

   //  [DllImport(datatype_dll, CallingConvention = CallingConvention.Cdecl)]
   //     private static extern Result_t _data_length(DataType_t d, out UInt32 max_size);


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
      if ({{ dn }}_registerDataType(PortBase.getBuffer()) < 0)
      {
         // Failed.
      }
    }

    public void up()
    {
      {{ dn }}_set(_d, {{ tile_calling_arguments(d, direction='in') }});
    }

    public void down()
    {
      {{ dn }}_get(_d, {{ tile_calling_arguments(d, direction='out') }});
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
  protected static const String datatype_dll = "{{ filename }}.dll";
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

 