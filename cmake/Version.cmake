set(STRAWBERRY_VERSION_MAJOR 0)
set(STRAWBERRY_VERSION_MINOR 1)
set(STRAWBERRY_VERSION_PATCH 5)
#set(STRAWBERRY_VERSION_PRERELEASE rc1)

set(INCLUDE_GIT_REVISION ON)

set(majorminorpatch "${STRAWBERRY_VERSION_MAJOR}.${STRAWBERRY_VERSION_MINOR}.${STRAWBERRY_VERSION_PATCH}")

set(STRAWBERRY_VERSION_DISPLAY "${majorminorpatch}")
set(STRAWBERRY_VERSION_RPM_V   "${majorminorpatch}")
set(STRAWBERRY_VERSION_RPM_R   "1")
set(STRAWBERRY_VERSION_PACKAGE "${majorminorpatch}")

if(${STRAWBERRY_VERSION_PATCH} EQUAL "0")
  set(STRAWBERRY_VERSION_DISPLAY "${STRAWBERRY_VERSION_MAJOR}.${STRAWBERRY_VERSION_MINOR}")
endif(${STRAWBERRY_VERSION_PATCH} EQUAL "0")

if(STRAWBERRY_VERSION_PRERELEASE)
  set(STRAWBERRY_VERSION_DISPLAY "${STRAWBERRY_VERSION_DISPLAY} ${STRAWBERRY_VERSION_PRERELEASE}")
  set(STRAWBERRY_VERSION_RPM_R   "0.${STRAWBERRY_VERSION_PRERELEASE}")
  set(STRAWBERRY_VERSION_PACKAGE "${STRAWBERRY_VERSION_PACKAGE}${STRAWBERRY_VERSION_PRERELEASE}")
endif(STRAWBERRY_VERSION_PRERELEASE)

find_program(GIT_EXECUTABLE git)

if(NOT GIT_EXECUTABLE-NOTFOUND)
  # Get the current working branch
  execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    RESULT_VARIABLE GIT_INFO_RESULT
    OUTPUT_VARIABLE GIT_BRANCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
  # Get the latest abbreviated commit hash of the working branch
  execute_process(
    COMMAND ${GIT_EXECUTABLE} describe --long --tags --always
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    RESULT_VARIABLE GIT_INFO_RESULT
    OUTPUT_VARIABLE GIT_REVISION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
endif()

if(${GIT_INFO_RESULT} EQUAL 0)
  set(HAS_GIT_REVISION ON)
  string(REGEX REPLACE "^(.+)-([0-9]+)-(g[a-f0-9]+)$" "\\1;\\2;\\3" GIT_PARTS ${GIT_REVISION})

  if(NOT GIT_PARTS)
    message(FATAL_ERROR "Failed to parse git revision string '${GIT_REVISION}'")
  endif(NOT GIT_PARTS)

  list(LENGTH GIT_PARTS GIT_PARTS_LENGTH)
  if(GIT_PARTS_LENGTH EQUAL 3)
    list(GET GIT_PARTS 0 GIT_TAGNAME)
    list(GET GIT_PARTS 1 GIT_COMMITCOUNT)
    list(GET GIT_PARTS 2 GIT_SHA1)
    set(HAS_GIT_REVISION ON)
  endif(GIT_PARTS_LENGTH EQUAL 3)
endif(${GIT_INFO_RESULT} EQUAL 0)

if(INCLUDE_GIT_REVISION AND HAS_GIT_REVISION)
  set(STRAWBERRY_VERSION_DISPLAY "${GIT_REVISION}")
  set(STRAWBERRY_VERSION_PACKAGE "${GIT_REVISION}")
  set(STRAWBERRY_VERSION_RPM_V   "${GIT_TAGNAME}")
  set(STRAWBERRY_VERSION_RPM_R   "2.${GIT_COMMITCOUNT}.${GIT_SHA1}")
endif(INCLUDE_GIT_REVISION AND HAS_GIT_REVISION)

message(STATUS "Strawberry Version:")
message(STATUS "Display:  ${STRAWBERRY_VERSION_DISPLAY}")
message(STATUS "Package:  ${STRAWBERRY_VERSION_PACKAGE}")
message(STATUS "Rpm:      ${STRAWBERRY_VERSION_RPM_V}-${STRAWBERRY_VERSION_RPM_R}")
