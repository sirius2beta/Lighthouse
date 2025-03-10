##
cmake_minimum_required(VERSION 3.25)

list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_SOURCE_DIR}/cmake
    ${CMAKE_SOURCE_DIR}/cmake/modules
    ${CMAKE_SOURCE_DIR}/cmake/find-modules
)

option(QGC_ENABLE_GST_VIDEOSTREAMING "Enable GStreamer Video Backend" ON)

include(FetchContent)
include(CMakePrintHelpers)
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
add_subdirectory(gstqml6gl)
add_subdirectory(dnapi)
target_link_libraries(${APP_NAME}
    PRIVATE
        LH
    PRIVATE
     Qt6::Quick
     gstqml6gl
)

include(GNUInstallDirs)
install(TARGETS ${APP_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

##
set(CMAKE_CXX_STANDARD 20)


##



