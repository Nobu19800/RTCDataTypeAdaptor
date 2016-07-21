cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

project({{ project.name }})
string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_LOWER)
set(PROJECT_VERSION {{ project.version }} CACHE STRING "{{ project.name }} version")
set(PROJECT_DESCRIPTION "{{ project.description }}")
set(PROJECT_VENDOR "{{ project.vendor }}")
set(PROJECT_AUTHOR "{{ project.author }}")
set(PROJECT_AUTHOR_SHORT "{{ project.author_short }}")

set(LIB_TYPE SHARED)

if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
   # Mac OS X specific code
   SET(CMAKE_CXX_COMPILER "g++")
endif (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

# Get necessary dependency information
#find_package(OpenRTM)
#if(${OpenRTM_FOUND})
#  MESSAGE(STATUS "OpenRTM configuration Found")
#else(${OpenRTM_FOUND})
#  message(STATUS "Use cmake/Modules/FindOpenRTM.cmake in the project")
#  list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules)
#  find_package(OpenRTM REQUIRED)
#endif(${OpenRTM_FOUND})

find_package(RTMAdapter)

add_subdirectory(idl)
add_subdirectory(include)
MAP_ADD_STR(headers  "include/" comp_hdrs)
add_subdirectory(src)

