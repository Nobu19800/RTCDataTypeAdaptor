set(_srcs {{ filename }}.cpp )
set(_test_srcs test.cpp )

if (DEFINED OPENRTM_INCLUDE_DIRS)
  string(REGEX REPLACE "-I" ";"
    OPENRTM_INCLUDE_DIRS "${OPENRTM_INCLUDE_DIRS}")
  string(REGEX REPLACE " ;" ";"
    OPENRTM_INCLUDE_DIRS "${OPENRTM_INCLUDE_DIRS}")
endif (DEFINED OPENRTM_INCLUDE_DIRS)

if (DEFINED OPENRTM_LIBRARY_DIRS)
  string(REGEX REPLACE "-L" ";"
    OPENRTM_LIBRARY_DIRS "${OPENRTM_LIBRARY_DIRS}")
  string(REGEX REPLACE " ;" ";"
    OPENRTM_LIBRARY_DIRS "${OPENRTM_LIBRARY_DIRS}")
endif (DEFINED OPENRTM_LIBRARY_DIRS)

if (DEFINED OPENRTM_LIBRARIES)
  string(REGEX REPLACE "-l" ";"
    OPENRTM_LIBRARIES "${OPENRTM_LIBRARIES}")
  string(REGEX REPLACE " ;" ";"
    OPENRTM_LIBRARIES "${OPENRTM_LIBRARIES}")
endif (DEFINED OPENRTM_LIBRARIES)

include_directories(${PROJECT_SOURCE_DIR}/include)
include_directories(${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME})
include_directories(${PROJECT_BINARY_DIR})
include_directories(${PROJECT_BINARY_DIR}/idl)
include_directories(${OPENRTM_INCLUDE_DIRS})
include_directories(${OMNIORB_INCLUDE_DIRS})
include_directories(${RTMADAPTER_INCLUDE_DIRS})
add_definitions(${OPENRTM_CFLAGS})
add_definitions(${OMNIORB_CFLAGS})

MAP_ADD_STR(comp_hdrs "../" comp_headers)

link_directories(${OPENRTM_LIBRARY_DIRS})
link_directories(${OMNIORB_LIBRARY_DIRS})
link_directories(${RTMADAPTER_LIBRARY_DIRS})

add_library(${PROJECT_NAME} ${LIB_TYPE} ${_srcs}
  ${comp_headers} ${ALL_IDL_SRCS})
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "")
set_source_files_properties(${ALL_IDL_SRCS} PROPERTIES GENERATED 1)
add_dependencies(${PROJECT_NAME} ALL_IDL_TGT ${PROJECT_NAME})
target_link_libraries(${PROJECT_NAME} ${OPENRTM_LIBRARIES} ${RTMADAPTER_LIBRARIES} )


add_executable(${PROJECT_NAME}Test ${_test_srcs}
  ${comp_headers} ${ALL_IDL_SRCS})
set_target_properties(${PROJECT_NAME}Test PROPERTIES PREFIX "")
set_source_files_properties(${ALL_IDL_SRCS} PROPERTIES GENERATED 1)
add_dependencies(${PROJECT_NAME}Test ALL_IDL_TGT ${PROJECT_NAME})
target_link_libraries(${PROJECT_NAME}Test ${PROJECT_NAME} ${OPENRTM_LIBRARIES} ${RTMADAPTER_LIBRARIES} )

