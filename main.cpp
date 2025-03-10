#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlEngine>
#include <gst/gst.h>
#include <QDebug>
#include "dnapplication.h"

int main(int argc, char *argv[])
{
    DNApplication* app = new DNApplication(argc, argv);

    Q_CHECK_PTR(app);
    int exitcode = 0;
    exitcode = app->exec();

    app->_shutdown();
    delete app;
    gst_deinit();
    return exitcode;
}
