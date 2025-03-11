# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\LH_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\LH_autogen.dir\\ParseCache.txt"
  "CMakeFiles\\Lighthouse_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\Lighthouse_autogen.dir\\ParseCache.txt"
  "LH_autogen"
  "Lighthouse_autogen"
  "dnapi\\CMakeFiles\\dnapi_autogen.dir\\AutogenUsed.txt"
  "dnapi\\CMakeFiles\\dnapi_autogen.dir\\ParseCache.txt"
  "dnapi\\dnapi_autogen"
  "gstqml6gl\\CMakeFiles\\gstqml6gl_autogen.dir\\AutogenUsed.txt"
  "gstqml6gl\\CMakeFiles\\gstqml6gl_autogen.dir\\ParseCache.txt"
  "gstqml6gl\\gstqml6gl_autogen"
  )
endif()
