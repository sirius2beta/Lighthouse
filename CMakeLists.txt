##
cmake_minimum_required(VERSION 3.25)

list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_SOURCE_DIR}/cmake
    ${CMAKE_SOURCE_DIR}/cmake/modules
    ${CMAKE_SOURCE_DIR}/cmake/find-modules
)

set(QGC_WINDOWS_ICON_PATH "${CMAKE_SOURCE_DIR}/deploy/windows/Lighthouse.ico" CACHE FILEPATH "Windows Icon Path")

option(QGC_ENABLE_GST_VIDEOSTREAMING "Enable GStreamer Video Backend" ON)

include(FetchContent)
include(CMakePrintHelpers)
include(CustomOptions)
##

project(Lighthouse VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(APP_NAME "Lighthouse")

find_package(Qt6 REQUIRED COMPONENTS Core Gui Network Qml QuickControls2 Widgets)


qt_standard_project_setup(REQUIRES 6.5)

list(APPEND QGC_RESOURCES
        ${CMAKE_SOURCE_DIR}/dnapi/DeNovo.qrc
        ${CMAKE_SOURCE_DIR}/dnapi/DNImage.qrc
        ${CMAKE_SOURCE_DIR}/DenovoUI/DenovoUI.qrc
)

set(CMAKE_AUTORCC ON)


# windows installer files shared with core and custom
 set(DEPLOY_WIN_FILES
     "${CMAKE_SOURCE_DIR}/deploy/windows/driver.msi"
     "${CMAKE_SOURCE_DIR}/deploy/windows/nullsoft_installer.nsi"
     "${CMAKE_SOURCE_DIR}/deploy/windows/QGroundControl.rc"
     "${QGC_WINDOWS_INSTALL_HEADER_PATH}"
     "${QGC_WINDOWS_ICON_PATH}"
 )



qt_add_executable(${APP_NAME}
    main.cpp
    ${QGC_RESOURCES}
)

qt_add_library(LH STATIC
    dnapplication.cpp
    dnapplication.h
)

target_link_libraries(LH
    PRIVATE
        Qt6::CorePrivate
        Qt6::Gui
        Qt6::Network
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
        gstqml6gl
        dnapi
    PUBLIC
        Qt6::Core
        Qt6::Widgets
)
target_include_directories(LH PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})


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



add_subdirectory(gstqml6gl)
add_subdirectory(dnapi)

install(TARGETS ${APP_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

target_link_libraries(${APP_NAME}
    PRIVATE
        LH
    PRIVATE
     Qt6::Quick
     gstqml6gl
)

include(GNUInstallDirs)

##
set(CMAKE_CXX_STANDARD 20)


##

include(Install)


