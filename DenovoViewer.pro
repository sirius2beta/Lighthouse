QT += quick gui widgets quickcontrols2 location multimedia

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

CONFIG += console

HEADERS += \
    dnapplication.h \

SOURCES += \
    main.cpp \
    dnapplication.cpp \


include(DNCommon.pri) #export to QGC

include(dnapi/QtQml.pri)

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# qgroundcontrol define
QT += \
        opengl \
        gui-private





