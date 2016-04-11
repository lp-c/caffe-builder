#.rst:
# FindZLIB
# --------
#
# Find the native ZLIB includes and library.
#
# IMPORTED Targets
# ^^^^^^^^^^^^^^^^
#
# This module defines :prop_tgt:`IMPORTED` target ``ZLIB::ZLIB``, if
# ZLIB has been found.
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module defines the following variables:
#
# ::
#
#   ZLIB_INCLUDE_DIRS   - where to find zlib.h, etc.
#   ZLIB_LIBRARIES      - List of libraries when using zlib.
#   ZLIB_FOUND          - True if zlib found.
#
# ::
#
#   ZLIB_VERSION_STRING - The version of zlib found (x.y.z)
#   ZLIB_VERSION_MAJOR  - The major version of zlib
#   ZLIB_VERSION_MINOR  - The minor version of zlib
#   ZLIB_VERSION_PATCH  - The patch version of zlib
#   ZLIB_VERSION_TWEAK  - The tweak version of zlib
#
# Backward Compatibility
# ^^^^^^^^^^^^^^^^^^^^^^
#
# The following variable are provided for backward compatibility
#
# ::
#
#   ZLIB_MAJOR_VERSION  - The major version of zlib
#   ZLIB_MINOR_VERSION  - The minor version of zlib
#   ZLIB_PATCH_VERSION  - The patch version of zlib
#
# Hints
# ^^^^^
#
# A user may set ``ZLIB_ROOT`` to a zlib installation root to tell this
# module where to look.

#=============================================================================
# Copyright 2001-2011 Kitware, Inc.
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

message(STATUS "Using custom FindZLIB module")

set(_ZLIB_SEARCHES)

set(ZLIB_ROOT ${CMAKE_CURRENT_LIST_DIR}/../zlib)

# Search ZLIB_ROOT first if it is set.
if(ZLIB_ROOT)
  set(_ZLIB_SEARCH_ROOT PATHS ${ZLIB_ROOT} NO_DEFAULT_PATH)
  list(APPEND _ZLIB_SEARCHES _ZLIB_SEARCH_ROOT)
endif()

set(ZLIB_SHARED @BUILD_SHARED_LIBS@)
if(ZLIB_SHARED)
  set(ZLIB_NAMES zlib)
else()
  set(ZLIB_NAMES zlibstatic)
endif()

# Try each search configuration.
foreach(search ${_ZLIB_SEARCHES})
  find_path(ZLIB_INCLUDE_DIR NAMES zlib.h        ${${search}} PATH_SUFFIXES include)
  find_library(ZLIB_LIBRARY  NAMES ${ZLIB_NAMES} ${${search}} PATH_SUFFIXES lib)
  find_library(ZLIB_LIBRARY_DEBUG  NAMES ${ZLIB_NAMES}d ${${search}} PATH_SUFFIXES lib)
endforeach()

mark_as_advanced(ZLIB_LIBRARY ZLIB_LIBRARY_DEBUG ZLIB_INCLUDE_DIR)

if(ZLIB_INCLUDE_DIR AND EXISTS "${ZLIB_INCLUDE_DIR}/zlib.h")
    file(STRINGS "${ZLIB_INCLUDE_DIR}/zlib.h" ZLIB_H REGEX "^#define ZLIB_VERSION \"[^\"]*\"$")

    string(REGEX REPLACE "^.*ZLIB_VERSION \"([0-9]+).*$" "\\1" ZLIB_VERSION_MAJOR "${ZLIB_H}")
    string(REGEX REPLACE "^.*ZLIB_VERSION \"[0-9]+\\.([0-9]+).*$" "\\1" ZLIB_VERSION_MINOR  "${ZLIB_H}")
    string(REGEX REPLACE "^.*ZLIB_VERSION \"[0-9]+\\.[0-9]+\\.([0-9]+).*$" "\\1" ZLIB_VERSION_PATCH "${ZLIB_H}")
    set(ZLIB_VERSION_STRING "${ZLIB_VERSION_MAJOR}.${ZLIB_VERSION_MINOR}.${ZLIB_VERSION_PATCH}")

    # only append a TWEAK version if it exists:
    set(ZLIB_VERSION_TWEAK "")
    if( "${ZLIB_H}" MATCHES "ZLIB_VERSION \"[0-9]+\\.[0-9]+\\.[0-9]+\\.([0-9]+)")
        set(ZLIB_VERSION_TWEAK "${CMAKE_MATCH_1}")
        set(ZLIB_VERSION_STRING "${ZLIB_VERSION_STRING}.${ZLIB_VERSION_TWEAK}")
    endif()

    set(ZLIB_MAJOR_VERSION "${ZLIB_VERSION_MAJOR}")
    set(ZLIB_MINOR_VERSION "${ZLIB_VERSION_MINOR}")
    set(ZLIB_PATCH_VERSION "${ZLIB_VERSION_PATCH}")
endif()

# handle the QUIETLY and REQUIRED arguments and set ZLIB_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(ZLIB REQUIRED_VARS ZLIB_LIBRARY ZLIB_INCLUDE_DIR
                                       VERSION_VAR ZLIB_VERSION_STRING)

if(ZLIB_FOUND)
    set(ZLIB_INCLUDE_DIRS ${ZLIB_INCLUDE_DIR})
    if(ZLIB_LIBRARY_DEBUG)
      set(ZLIB_LIBRARIES optimized ${ZLIB_LIBRARY} debug ${ZLIB_LIBRARY_DEBUG} CACHE FILEPATH "ZLIB libraries for release and debug" FORCE)      
    else()
      set(ZLIB_LIBRARIES ${ZLIB_LIBRARY})
    endif()    
    
    if(NOT TARGET ZLIB::ZLIB)
      add_library(ZLIB::ZLIB UNKNOWN IMPORTED)
      set_target_properties(ZLIB::ZLIB PROPERTIES
        IMPORTED_LOCATION "${ZLIB_LIBRARY}"
        IMPORTED_LOCATION_RELEASE "${ZLIB_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${ZLIB_INCLUDE_DIRS}")
      if(ZLIB_LIBRARY_DEBUG)
        set_target_properties(ZLIB::ZLIB PROPERTIES
          IMPORTED_LOCATION_DEBUG "${ZLIB_LIBRARY_DEBUG}"
          )
      endif()
    endif()
    
    set(ZLIB_LIBRARIES ZLIB::ZLIB)    
endif()