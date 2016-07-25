cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

project({{ project.name }})
string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_LOWER)
include("${PROJECT_SOURCE_DIR}/cmake/utils.cmake")
set(PROJECT_VERSION {{ project.version }} CACHE STRING "{{ project.name }} version")
DISSECT_VERSION()
set(PROJECT_DESCRIPTION "{{ project.description }}")
set(PROJECT_VENDOR "{{ project.vendor }}")
set(PROJECT_AUTHOR "{{ project.author }}")
set(PROJECT_AUTHOR_SHORT "{{ project.author_short }}")

set(LIB_TYPE SHARED)

# Add an "uninstall" target
CONFIGURE_FILE ("${PROJECT_SOURCE_DIR}/cmake/uninstall_target.cmake.in"
    "${PROJECT_BINARY_DIR}/uninstall_target.cmake" IMMEDIATE @ONLY)
ADD_CUSTOM_TARGET (uninstall "${CMAKE_COMMAND}" -P
    "${PROJECT_BINARY_DIR}/uninstall_target.cmake")

if (${CMAKE_SYSTEM_NAME} MATCHES "Windows") 
  set(BIN_INSTALL_DIR "bin")
  set(LIB_INSTALL_DIR "lib")
  set(CMAKE_INSTALL_DIR "cmake")
  set(INC_INSTALL_DIR
    "include/${PROJECT_NAME}-${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")
  set(SHARE_INSTALL_DIR
    "share/${PROJECT_NAME}-${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")

  if (CMAKE_CL_64)
    set(SYSDIR $ENV{SYSTEMROOT}\\system32)
  else (CMAKE_CL_64)
    set(SYSDIR $ENV{SYSTEMROOT}\\syswow64)
  endif(CMAKE_CL_64)

  set (SYS_INSTALL_DIR ${SYSDIR})

else ()
  set(BIN_INSTALL_DIR "bin")
  set(LIB_INSTALL_DIR "lib")
  set(CMAKE_INSTALL_DIR "cmake")
  set(INC_INSTALL_DIR
    "include/${PROJECT_NAME}-${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")
  set(SHARE_INSTALL_DIR
    "share/${PROJECT_NAME}-${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")
endif ()

if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
   # Mac OS X specific code
   SET(CMAKE_CXX_COMPILER "g++")
endif (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

find_package(RTMAdapter)

add_subdirectory(idl)
add_subdirectory(cmake)
add_subdirectory(include)
MAP_ADD_STR(headers  "include/" comp_hdrs)
add_subdirectory(src)

