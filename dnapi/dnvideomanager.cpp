﻿#include "dnvideomanager.h"
#include "dnapplication.h"
#include "dncore.h"
//#include "QGCApplication.h"
#include <QQmlEngine>
#include <QQuickItem>
#include <cstring>


DNVideoManager::DNVideoManager(QObject *parent, DNCore* core)
    : QObject{parent},
      _core(core)
{
    QCoreApplication::setOrganizationName("Ezosirius");
    QCoreApplication::setApplicationName("GPlayer_v1");
    settings = new QSettings;

}

DNVideoManager::~DNVideoManager()
{
    //gst_element_set_state (_testpipeline, GST_STATE_NULL);
    //gst_object_unref (_testpipeline);

}

void DNVideoManager::init()
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    int window_count = 4;
    QString _config = _core->config();
    for(int i = 0; i < window_count; i++){
        //create settings if first time opened
        if(settings->value(QString("%1/w%2/in_port").arg(_config,QString::number(i))) == QVariant()){
            QList<QString> formatlist = {"video0", "YUYV", "640-480-15", "nan", "80", "192.168.0.100", "5200"};
            settings->setValue(QString("%1/w%2/boat_name").arg(_config,QString::number(i)),QString("unknown"));
            settings->setValue(QString("%1/w%2/in_port").arg(_config,QString::number(i)),5200+i);
            settings->setValue(QString("%1/w%2/title").arg(_config,QString::number(i)),QString("window%1").arg(i));
            settings->setValue(QString("%1/w%2/videoinfo").arg(_config,QString::number(i)), 1);
            settings->setValue(QString("%1/w%2/formatno").arg(_config,QString::number(i)), 0);
        }
        QString title = settings->value(QString("%1/w%2/title").arg(_config,QString::number(i))).toString();

        int PCPort = 5201+i;

        addVideoItem(i, title, -1, -1, -1, PCPort);

    }


}

void DNVideoManager::initVideo()
{
    //有幾個視窗開幾個
    QQuickWindow* root = dnApp()->mainRootWindow();
    QQuickItem* widget0 = root->findChild<QQuickItem*>("videoContent0");
    videoList[0]->initVideo(widget0);
    QQuickItem* widget1 = root->findChild<QQuickItem*>("videoContent1");
    videoList[1]->initVideo(widget1);
    //QQuickItem* widget2 = root->findChild<QQuickItem*>("videoContent2");
    //videoList[2]->initVideo(widget2);
}

void DNVideoManager::initGstreamer()
{
    //_testpipeline = gst_parse_launch("videotestsrc ! glupload ! qml6glsink name=sink",NULL);
    //_testsink = gst_bin_get_by_name((GstBin*)_testpipeline,"sink");
}

void DNVideoManager::setVideoTest(QQuickItem* widget)
{

    GstElement* qmlglsink;
    if ((qmlglsink = gst_element_factory_make("qmlglsink ", NULL)) == NULL) {
        qDebug()<<"\u001b[38;5;203m"<<"**Fatal qmlglsink failed"<<"\033[0m";
    }
    _testpipeline = gst_parse_launch("videotestsrc ! glupload ! glcolorconvert ! qmlglsink name=sink",NULL);
    _testsink = gst_bin_get_by_name((GstBin*)_testpipeline,"sink");
    g_object_set(_testsink, "widget", widget, NULL);
    gst_element_set_state (_testpipeline, GST_STATE_PLAYING);
}

void DNVideoManager::addVideoItem(int index, QString title, int boatID, int videoNo, int formatNo, int PCPort)
{
    VideoItem* newvideoitem = new VideoItem(this, _core, index, title, boatID, videoNo, formatNo, PCPort);
    QQmlEngine::setObjectOwnership(newvideoitem, QQmlEngine::CppOwnership);
    if(settings->value(QString("%1/w%2/videoinfo").arg(_core->config(),QString::number(newvideoitem->index()))) == 1){
        newvideoitem->setVideoInfo(true);
    }else{
        newvideoitem->setVideoInfo(false);
    }
    videoList.append(newvideoitem);
    connect(newvideoitem, &VideoItem::videoPlayed, this, &DNVideoManager::onPlay);
    connect(newvideoitem, &VideoItem::videoStoped, this, &DNVideoManager::onStop);
    connect(newvideoitem, &VideoItem::requestFormat, this, &DNVideoManager::onRequestFormat);

}

void DNVideoManager::onPlay(VideoItem* videoItem)
{
    QHostAddress ip = QHostAddress(_core->boatManager()->getBoatbyID(videoItem->boatID())->currentIP());
    char rawdata[7];

    uint8_t videoInexraw = videoItem->videoNo();
    uint8_t formatIndexraw = videoItem->formatIndex();
    uint8_t encoder = videoItem->encoder() == QString("h264")? 0:1;
    int32_t port = videoItem->port();

    memcpy(rawdata, &videoInexraw, sizeof(uint8_t));
    memcpy(rawdata+1, &formatIndexraw, sizeof(uint8_t));
    memcpy(rawdata+2, &encoder, sizeof(uint8_t));

    memcpy(rawdata+3, &port, sizeof(int32_t));
    QByteArray msg = QByteArray(rawdata,7);
    qDebug()<<"DNVideoManager::onPlay:send: "+msg;
    //if(msg == QString("")) return;
    emit sendMsg(ip, _core->configManager()->message("COMMAND"), msg);
}

void DNVideoManager::onStop(VideoItem* videoItem)
{

    if(videoItem->videoNo() == -1){
        return;
    }

    QString videoNo = QString("video")+QString::number(videoItem->videoNo());
    if(_core->boatManager()->getBoatbyID(videoItem->boatID()) == 0){
        qDebug()<<"\u001b[38;5;203m"<<"Fatal:: DNVideoManager::onStop, boat ID:"<< videoItem->boatID()<<" not exist"<<"\033[0m";
        return;
    }
    QHostAddress ip = QHostAddress(_core->boatManager()->getBoatbyID(videoItem->boatID())->currentIP());
    emit sendMsg(ip, _core->configManager()->message("QUIT"), videoNo.toLocal8Bit());

}

void DNVideoManager::onBoatAdded()
{
    /*
    for(int i = 0; i<videoList.size(); i++){
        if(videoList[i]->boatID() == -1){
            videoList[i]->setVideoIndex(0);
        }
    }
    */
}

void DNVideoManager::onRequestFormat(VideoItem* videoItem)
{
    QHostAddress addr(_core->boatManager()->getBoatbyID(videoItem->boatID())->currentIP());
    qDebug()<<"DNVideoManager::onRequestFormat: currentIP:"<<_core->boatManager()->getBoatbyID(videoItem->boatID())->currentIP();
    emit sendMsg(addr, _core->configManager()->message("FORMAT"), "");
}

void DNVideoManager::setVideoFormat(int ID, QByteArray data)
{
    for(int i = 0; i < videoList.size(); i++){
        if(videoList[i]->boatID() == ID){
            qDebug()<<"set format, index:"<<_core->boatManager()->getIndexbyID(ID);
            videoList[i]->setVideoFormat(data);
        }
    }
}

void DNVideoManager::onConnectionChanged(int connectionType)
{
    for(int i = 0; i < videoList.size(); i++){
        videoList[i]->setConnectionPriority(connectionType);
    }
}

void DNVideoManager::connectionChanged(int ID)
{
    qDebug()<<"DNVideoManager::connectionChanged: "<<ID;
    for(int i = 0; i < videoList.size(); i++){
        if(videoList[i]->boatID() == ID){
            if(videoList[i]->isPlaying()){
                videoList[i]->stop();
                videoList[i]->play();
            }

        }
    }
}
