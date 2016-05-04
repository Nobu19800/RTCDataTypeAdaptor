set(headers {{ filename }}.h )


macro(MAP_ADD_STR _list _str _output)
    set(${_output})
    foreach(_item ${${_list}})
        set(${_output} ${${_output}} ${_str}${_item})
    endforeach(_item)
endmacro(MAP_ADD_STR)


MAP_ADD_STR(hdrs "${PROJECT_NAME}/" headers)
set(headers ${headers} PARENT_SCOPE)
