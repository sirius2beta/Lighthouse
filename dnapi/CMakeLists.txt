find_package(Qt6 REQUIRED COMPONENTS Core Network Qml Gui Quick)

qt_add_library(dnapi STATIC
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
    videoitem.cpp
    videoitem.h
    winchcontrol.cpp
    winchcontrol.h
)

target_link_libraries(dnapi
    PRIVATE
        Qt6::Qml
        LH
    PUBLIC
        Qt6::Core
        Qt6::Network
        Qt6::Gui
        Qt6::Quick
        gstqml6gl
)

target_include_directories(dnapi PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
