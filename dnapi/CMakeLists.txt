find_package(Qt6 REQUIRED COMPONENTS Core Network Qml Gui Quick)

target_sources(${CMAKE_PROJECT_NAME} PRIVATE
    boatitem.cpp
    boatitem.h
    boatmanager.cpp
    boatmanager.h
    configmanager.cpp
    configmanager.h
    controlitem.cpp
    controlitem.h
    controlmanager.cpp
    controlmanager.h
    device.cpp
    device.h
    dncontrol.cpp
    dncontrol.h
    dncore.cpp
    dncore.h
    aquagraph.h

    dnmetadata.cpp
    dnmetadata.h
    dnqmlglobal.cpp
    dnqmlglobal.h
    dnqmlobjectlistmodel.cpp
    dnqmlobjectlistmodel.h
    dnvalue.cpp
    dnvalue.h
    dnvideomanager.cpp
    dnvideomanager.h
    heartbeat.cpp
    heartbeat.h
    networkmanager.cpp
    networkmanager.h
    sensorgroup.cpp
    sensorgroup.h
    sensoritem.cpp
    sensoritem.h
    sensormanager.cpp
    sensormanager.h
    sonarcontrol.cpp
    sonarcontrol.h
    videoitem.cpp
    videoitem.h
    winchcontrol.cpp
    winchcontrol.h
    aquagraph.cpp

)

target_link_libraries(${CMAKE_PROJECT_NAME}
    PRIVATE
        Qt6::Qml
    PUBLIC
        Qt6::Core
        Qt6::Network
        Qt6::Gui
        Qt6::Quick
)

target_include_directories(${CMAKE_PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
add_subdirectory(GStreamer)
#add_subdirectory(Android)
