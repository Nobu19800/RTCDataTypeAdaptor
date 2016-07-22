set(_srcs {{ filename }}.cpp )
set(_test_srcs test.c )


include_directories(${PROJECT_SOURCE_DIR}/include)
include_directories(${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME})
include_directories(${PROJECT_BINARY_DIR})
include_directories(${PROJECT_BINARY_DIR}/idl)
include_directories(${RTMAdapter_INCLUDE_DIRS})

add_definitions(${RTMAdapter_DEFINITIONS})

MAP_ADD_STR(comp_hdrs "../" comp_headers)

link_directories(${RTMAdapter_LIBRARY_DIRS})

add_library(${PROJECT_NAME} ${LIB_TYPE} ${_srcs}
  ${comp_headers} ${ALL_IDL_SRCS})
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "")
set_source_files_properties(${ALL_IDL_SRCS} PROPERTIES GENERATED 1)
add_dependencies(${PROJECT_NAME} ALL_IDL_TGT ${PROJECT_NAME})
set_target_properties(${PROJECT_NAME} PROPERTIES DEBUG_POSTFIX "d")
target_link_libraries(${PROJECT_NAME} ${RTMAdapter_LIBRARIES} )


add_executable(${PROJECT_NAME}Test ${_test_srcs}
  ${comp_headers} ${ALL_IDL_SRCS})
set_target_properties(${PROJECT_NAME}Test PROPERTIES PREFIX "")
set_source_files_properties(${ALL_IDL_SRCS} PROPERTIES GENERATED 1)
add_dependencies(${PROJECT_NAME}Test ALL_IDL_TGT ${PROJECT_NAME})
set_target_properties(${PROJECT_NAME} PROPERTIES DEBUG_POSTFIX "d")
target_link_libraries(${PROJECT_NAME}Test ${PROJECT_NAME} ${RTMAdapter_LIBRARIES} )



if (${CMAKE_SYSTEM_NAME} MATCHES Windows) 

  install(TARGETS ${PROJECT_NAME} 
    EXPORT ${PROJECT_NAME}
    RUNTIME DESTINATION ${BIN_INSTALL_DIR} COMPONENT
    LIBRARY DESTINATION ${LIB_INSTALL_DIR} COMPONENT
    ARCHIVE DESTINATION ${LIB_INSTALL_DIR} COMPONENT
    )

  install(FILES ${CMAKE_BINARY_DIR}/src/\${CMAKE_INSTALL_CONFIG_NAME}/${PROJECT_NAME}d.dll DESTINATION ${SYS_INSTALL_DIR} CONFIGURATIONS Debug)
  install(FILES ${CMAKE_BINARY_DIR}/src/\${CMAKE_INSTALL_CONFIG_NAME}/${PROJECT_NAME}.dll DESTINATION ${SYS_INSTALL_DIR} CONFIGURATIONS Release)
  
  message(${CMAKE_BINARY_DIR})
else (${CMAKE_SYSTEM_NAME} MATCHES Windows) 

  install(TARGETS ${PROJECT_NAME} 
    EXPORT ${PROJECT_NAME}
    RUNTIME DESTINATION ${BIN_INSTALL_DIR} COMPONENT
    LIBRARY DESTINATION ${LIB_INSTALL_DIR} COMPONENT
    ARCHIVE DESTINATION ${LIB_INSTALL_DIR} COMPONENT)

endif (${CMAKE_SYSTEM_NAME} MATCHES Windows)

install(EXPORT ${PROJECT_NAME}
    DESTINATION ${LIB_INSTALL_DIR}/${PROJECT_NAME}
    FILE ${PROJECT_NAME}Depends.cmake
    )

