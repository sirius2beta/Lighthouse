#- gstreamer installed by default under c:/gstreamer
GST_ROOT = c:/gstreamer/1.0/msvc_x86_64

!exists($$GST_ROOT) {
    # In GitHub actions windows runner installation is on D drive, so try there as well
    GST_ROOT = d:/gstreamer/1.0/msvc_x86_64
}

exists($$GST_ROOT) {
    CONFIG      += VideoEnabled

    LIBS        += -L$$GST_ROOT/lib -lgstreamer-1.0 -lgstgl-1.0 -lgstvideo-1.0 -lgstbase-1.0
    LIBS        += -lglib-2.0 -lintl -lgobject-2.0

    INCLUDEPATH += \
        $$GST_ROOT/include \
        $$GST_ROOT/include/gstreamer-1.0 \
        $$GST_ROOT/include/glib-2.0 \
        $$GST_ROOT/lib/gstreamer-1.0/include \
        $$GST_ROOT/lib/glib-2.0/include

    DESTDIR_WIN = $$replace(DESTDIR, "/", "\\")
    GST_ROOT_WIN = $$replace(GST_ROOT, "/", "\\")


}


DEFINES += HAVE_QT_WIN32 HAVE_QT_QPA_HEADER
LIBS += opengl32.lib user32.lib

SOURCES += \
    dnapi/libs/ext/qt/gstplugin.cc \
    dnapi/libs/ext/qt/gstqtglutility.cc \
    dnapi/libs/ext/qt/gstqsgtexture.cc \
    dnapi/libs/ext/qt/gstqtsink.cc \
    dnapi/libs/ext/qt/gstqtsrc.cc \
    dnapi/libs/ext/qt/qtwindow.cc \
    dnapi/libs/ext/qt/qtitem.cc

HEADERS += \
    dnapi/libs/ext/qt/gstqsgtexture.h \
    dnapi/libs/ext/qt/gstqtgl.h \
    dnapi/libs/ext/qt/gstqtglutility.h \
    dnapi/libs/ext/qt/gstqtsink.h \
    dnapi/libs/ext/qt/gstqtsrc.h \
    dnapi/libs/ext/qt/qtwindow.h \
    dnapi/libs/ext/qt/qtitem.h
