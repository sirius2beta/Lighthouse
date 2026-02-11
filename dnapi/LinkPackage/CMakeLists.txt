

target_sources(${CMAKE_PROJECT_NAME}
    PRIVATE
    LinkPackage.qrc
    Bridge.h Bridge.cpp
    LinkConfiguration.h linkConfiguration.cpp
    LinkInterface.h LinkInterface.cpp
    MAVLinkProtocol.h
    MAVLinkProtocol.cpp
    MAVLinkLib.h

    LinkManager.h LinkManager.cpp
    SerialLink.h SerialLink.cc
    UDPLink.h UDPLink.cc
    UdpIODevice.cc UdpIODevice.h
    QGCSerialPortInfo.h QGCSerialPortInfo.cc
    JsonHelper.h JsonHelper.cc

)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
