# {{ filename }} CMake config file
#
# This file sets the following variables:
# {{ filename }}_FOUND - Always TRUE.
# {{ filename }}_INCLUDE_DIRS - Directories containing the {{ filename }} include files.
# {{ filename }}_IDL_DIRS - Directories containing the {{ filename }} IDL files.
# {{ filename }}_LIBRARIES - Libraries needed to use {{ filename }}.
# {{ filename }}_DEFINITIONS - Compiler flags for {{ filename }}.
# {{ filename }}_VERSION - The version of {{ filename }} found.
# {{ filename }}r_VERSION_MAJOR - The major version of {{ filename }} found.
# {{ filename }}_VERSION_MINOR - The minor version of {{ filename }} found.
# {{ filename }}_VERSION_REVISION - The revision version of {{ filename }} found.
# {{ filename }}_VERSION_CANDIDATE - The candidate version of {{ filename }} found.

message(STATUS "Found {{ filename }}-@PROJECT_VERSION@")
set({{ filename }}_FOUND TRUE)

find_package(RTMAdapter REQUIRED)
if(${RTMAdapter_FOUND})
  MESSAGE(STATUS "RTMAdapter configuration Found in {{ filename }}.cmake")
endif(${RTMAdapter_FOUND})


set({{ filename }}_INCLUDE_DIRS
    "@CMAKE_INSTALL_PREFIX@/include/@CPACK_PACKAGE_FILE_NAME@"
    ${RTMAdapter_INCLUDE_DIRS}
    )
#set({{ filename }}_IDL_DIRS
#    "@CMAKE_INSTALL_PREFIX@/include/@CPACK_PACKAGE_FILE_NAME@/idl")

set({{ filename }}_LIBRARY_DIRS
    "@CMAKE_INSTALL_PREFIX@/lib/"
    ${RTMAdapter_LIBRARY_DIRS}
)

if(WIN32)
    set({{ filename }}_LIBRARIES
        optimized;@CMAKE_SHARED_LIBRARY_PREFIX@@PROJECT_NAME@@CMAKE_STATIC_LIBRARY_SUFFIX@;debug;@CMAKE_SHARED_LIBRARY_PREFIX@@PROJECT_NAME@d@CMAKE_STATIC_LIBRARY_SUFFIX@;
        ${RTMAdapter_LIBRARIES}
        )
else(WIN32)
    set({{ filename }}_LIBRARIES
        "optimized;@CMAKE_INSTALL_PREFIX@/@CMAKE_SHARED_LIBRARY_PREFIX@@PROJECT_NAME@@CMAKE_STATIC_LIBRARY_SUFFIX@;debug;@CMAKE_INSTALL_PREFIX@/@CMAKE_SHARED_LIBRARY_PREFIX@@PROJECT_NAME@d@CMAKE_STATIC_LIBRARY_SUFFIX@"
        ${RTMAdapter_LIBRARIES}
        )
endif(WIN32)

set({{ filename }}_DEFINITIONS ${RTMAdapter_DEFINITIONS})

set({{ filename }}_VERSION @PROJECT_VERSION@)
set({{ filename }}_VERSION_MAJOR @PROJECT_VERSION_MAJOR@)
set({{ filename }}_VERSION_MINOR @PROJECT_VERSION_MINOR@)
set({{ filename }}_VERSION_REVISION @PROJECT_VERSION_REVISION@)
set({{ filename }}_VERSION_CANDIDATE @PROJECT_VERSION_CANDIDATE@)

