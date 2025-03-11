# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "C:/Project/New_repo/Lighthouse/build/Desktop_Qt_6_8_2_MSVC2022_64bit-Debug/_deps/gstreamer_good_plugins-src"
  "C:/Project/New_repo/Lighthouse/build/Desktop_Qt_6_8_2_MSVC2022_64bit-Debug/_deps/gstreamer_good_plugins-build"
  "C:/Project/New_repo/Lighthouse/build/Desktop_Qt_6_8_2_MSVC2022_64bit-Debug/_deps/gstreamer_good_plugins-subbuild/gstreamer_good_plugins-populate-prefix"
  "C:/Project/New_repo/Lighthouse/build/Desktop_Qt_6_8_2_MSVC2022_64bit-Debug/_deps/gstreamer_good_plugins-subbuild/gstreamer_good_plugins-populate-prefix/tmp"
  "C:/Project/New_repo/Lighthouse/build/Desktop_Qt_6_8_2_MSVC2022_64bit-Debug/_deps/gstreamer_good_plugins-subbuild/gstreamer_good_plugins-populate-prefix/src/gstreamer_good_plugins-populate-stamp"
  "C:/Project/New_repo/Lighthouse/build/Desktop_Qt_6_8_2_MSVC2022_64bit-Debug/_deps/gstreamer_good_plugins-subbuild/gstreamer_good_plugins-populate-prefix/src"
  "C:/Project/New_repo/Lighthouse/build/Desktop_Qt_6_8_2_MSVC2022_64bit-Debug/_deps/gstreamer_good_plugins-subbuild/gstreamer_good_plugins-populate-prefix/src/gstreamer_good_plugins-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "C:/Project/New_repo/Lighthouse/build/Desktop_Qt_6_8_2_MSVC2022_64bit-Debug/_deps/gstreamer_good_plugins-subbuild/gstreamer_good_plugins-populate-prefix/src/gstreamer_good_plugins-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "C:/Project/New_repo/Lighthouse/build/Desktop_Qt_6_8_2_MSVC2022_64bit-Debug/_deps/gstreamer_good_plugins-subbuild/gstreamer_good_plugins-populate-prefix/src/gstreamer_good_plugins-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
