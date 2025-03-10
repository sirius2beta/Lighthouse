TEMPLATE = lib

TARGET = gstqmlgl

QT += qml quick gui-private core

QT_CONFIG -= no-pkg-config
CONFIG += link_pkgconfig debug
PKGCONFIG = \
    gstreamer-1.0 \
    gstreamer-video-1.0 \
    gstreamer-gl-1.0

android {
    CONFIG += static
} else {
    CONFIG += plugin
}

android:DEFINES += HAVE_QT_ANDROID
win32:DEFINES += HAVE_QT_WIN32 HAVE_QT_QPA_HEADER
macx:DEFINES += HAVE_QT_MAC

versionAtLeast(QT_VERSION, "5.5"):win32-msvc: LIBS += opengl32.lib user32.lib

SOURCES += \
    gstplugin.cc \
    gstqml6glsink.cc \
    gstqsg6glnode.cc \
    gstqt6element.cc \
    gstqt6glutility.cc \
    qt6glitem.cc \


HEADERS += \
    gstqml6glsink.h \
    gstqsg6glnode.h \
    gstqt6element.h \
    gstqt6gl.h \
    gstqt6glutility.h \
    qt6glitem.h \
