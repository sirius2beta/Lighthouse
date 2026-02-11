##
cmake_minimum_required(VERSION 3.25)

list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_SOURCE_DIR}/cmake
    ${CMAKE_SOURCE_DIR}/cmake/modules
    ${CMAKE_SOURCE_DIR}/cmake/find-modules
)

set(QGC_WINDOWS_ICON_PATH "${CMAKE_SOURCE_DIR}/deploy/windows/logo.ico" CACHE FILEPATH "Windows Icon Path")

option(QGC_ENABLE_GST_VIDEOSTREAMING "Enable GStreamer Video Backend" ON)

include(FetchContent)
include(CMakePrintHelpers)
include(CustomOptions)
include(CPM)

##

project(Lighthouse VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTORCC ON)


set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(APP_NAME "Lighthouse")

if(CMAKE_CROSSCOMPILING)
    if(ANDROID)
        set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
        set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
        set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)
    endif()

    if(NOT IS_DIRECTORY ${QT_HOST_PATH})
        message(FATAL_ERROR "You need to set QT_HOST_PATH to cross compile Qt.")
    endif()
endif()

find_package(Qt6 REQUIRED COMPONENTS Core Gui Network Qml QuickControls2 SerialPort Widgets)


qt_standard_project_setup(REQUIRES 6.5)

list(APPEND QGC_RESOURCES
        ${CMAKE_SOURCE_DIR}/dnapi/DeNovo.qrc
        ${CMAKE_SOURCE_DIR}/dnapi/DNImage.qrc
        ${CMAKE_SOURCE_DIR}/DenovoUI/DenovoUI.qrc
)




# windows installer files shared with core and custom
 set(DEPLOY_WIN_FILES
     "${CMAKE_SOURCE_DIR}/deploy/windows/driver.msi"
     "${CMAKE_SOURCE_DIR}/deploy/windows/nullsoft_installer.nsi"
     "${CMAKE_SOURCE_DIR}/deploy/windows/QGroundControl.rc"
     "${QGC_WINDOWS_INSTALL_HEADER_PATH}"
     "${QGC_WINDOWS_ICON_PATH}"
 )



qt_add_executable(${CMAKE_PROJECT_NAME}
    main.cpp
    dnapplication.cpp
    dnapplication.h
    ${QGC_RESOURCES}
)



target_link_libraries(${CMAKE_PROJECT_NAME}
    PRIVATE
        Qt6::CorePrivate
        Qt6::Gui
        Qt6::Network
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::SerialPort
        gstqml6gl

    PUBLIC
        Qt6::Core
        Qt6::Widgets
)


# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(${APP_NAME} PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appuntitled10
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)



# Destination directory where files will be copied
set(QGC_INSTALLER_SOURCE_WIN "${CMAKE_BINARY_DIR}/deploy/windows")
file(MAKE_DIRECTORY ${QGC_INSTALLER_SOURCE_WIN})
foreach(FILE ${DEPLOY_WIN_FILES})
    # filename without the path
    get_filename_component(FILE_NAME ${FILE} NAME)
    # re-copy the file if it changes
    add_custom_command(
        OUTPUT "${QGC_INSTALLER_SOURCE_WIN}/${FILE_NAME}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${FILE}" "${QGC_INSTALLER_SOURCE_WIN}/${FILE_NAME}"
        DEPENDS "${FILE}"  # Depend on the source file so that it re-copies when it changes
    )
    list(APPEND QGC_INSTALLER_SOURCE_WIN_FILES "${QGC_INSTALLER_SOURCE_WIN}/${FILE_NAME}")
endforeach()

target_sources(${CMAKE_PROJECT_NAME} PRIVATE ${QGC_INSTALLER_SOURCE_WIN_FILES})
set_target_properties(${CMAKE_PROJECT_NAME}
    PROPERTIES
        WIN32_EXECUTABLE TRUE
        QT_TARGET_RC_ICONS "${QGC_WINDOWS_ICON_PATH}"
)
add_compile_definitions(_USE_MATH_DEFINES)



add_subdirectory(dnapi)

install(TARGETS ${APP_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/$<CONFIGURATION>/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/$<CONFIGURATION>)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/$<CONFIGURATION>)

target_link_libraries(${CMAKE_PROJECT_NAME}

    PRIVATE
     Qt6::Quick
)

include(GNUInstallDirs)

##
set(CMAKE_CXX_STANDARD 20)


##

include(Install)





