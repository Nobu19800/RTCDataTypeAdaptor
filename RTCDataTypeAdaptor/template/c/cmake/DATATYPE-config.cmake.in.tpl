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

find_package(OpenRTM REQUIRED)
if(${OpenRTM_FOUND})
  MESSAGE(STATUS "OpenRTM configuration Found in RTMAdaptger.cmake")
endif(${OpenRTM_FOUND})


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

#set({{ filename }}_INCLUDE_DIRS
#    "@CMAKE_INSTALL_PREFIX@/include/@PROJECT_NAME_LOWER@-@PROJECT_VERSION_MAJOR@"
#    ${<dependency>_INCLUDE_DIRS}
#    )
#
#set({{ filename }}_IDL_DIRS
#    "@CMAKE_INSTALL_PREFIX@/include/@PROJECT_NAME_LOWER@-@PROJECT_VERSION_MAJOR@/idl")
set({{ filename }}_INCLUDE_DIRS
    "@CMAKE_INSTALL_PREFIX@/include/@CPACK_PACKAGE_FILE_NAME@"
    ${OPENRTM_INCLUDE_DIRS}
    ${OMNIORB_INCLUDE_DIRS}
    )
#set({{ filename }}_IDL_DIRS
#    "@CMAKE_INSTALL_PREFIX@/include/@CPACK_PACKAGE_FILE_NAME@/idl")

set({{ filename }}_LIBRARY_DIRS
    "@CMAKE_INSTALL_PREFIX@/lib/"
    ${OPENRTM_LIBRARY_DIRS}
    ${OMNIORB_LIBRARY_DIRS}
)

if(WIN32)
    set({{ filename }}_LIBRARIES
        optimized;@CMAKE_SHARED_LIBRARY_PREFIX@@PROJECT_NAME@@CMAKE_STATIC_LIBRARY_SUFFIX@;debug;@CMAKE_SHARED_LIBRARY_PREFIX@@PROJECT_NAME@d@CMAKE_STATIC_LIBRARY_SUFFIX@;
        ${OPENRTM_LIBRARIES}
        )
else(WIN32)
    set({{ filename }}_LIBRARIES
        "optimized;@CMAKE_INSTALL_PREFIX@/@CMAKE_SHARED_LIBRARY_PREFIX@@PROJECT_NAME@@CMAKE_STATIC_LIBRARY_SUFFIX@;debug;@CMAKE_INSTALL_PREFIX@/@CMAKE_SHARED_LIBRARY_PREFIX@@PROJECT_NAME@d@CMAKE_STATIC_LIBRARY_SUFFIX@"
        ${OPENRTM_LIBRARIES}
        )
endif(WIN32)

set({{ filename }}_DEFINITIONS ${OPENRTM_CFLAGS} ${OMNIORB_CFLAGS})

set({{ filename }}_VERSION @PROJECT_VERSION@)
set({{ filename }}_VERSION_MAJOR @PROJECT_VERSION_MAJOR@)
set({{ filename }}_VERSION_MINOR @PROJECT_VERSION_MINOR@)
set({{ filename }}_VERSION_REVISION @PROJECT_VERSION_REVISION@)
set({{ filename }}_VERSION_CANDIDATE @PROJECT_VERSION_CANDIDATE@)

