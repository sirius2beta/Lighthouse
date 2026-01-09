#include "dnvideomanager.h"
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

void DNVideoManager::addVideoItem(int index, QString title, int boatID, int videoNo, int qualityIndex, int PCPort)
{
    VideoItem* newvideoitem = new VideoItem(this, _core, index, title, boatID, videoNo, qualityIndex, PCPort);
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
    connect(newvideoitem, &VideoItem::setAsSeagrassCameraSignal, this, &DNVideoManager::onSettingSeagrassCamera);
    connect(newvideoitem, &VideoItem::startSeagrassCameraRecordingSignal, this, &DNVideoManager::onStartSeagrassCameraRecording);
    connect(newvideoitem, &VideoItem::stopSeagrassCameraRecordingSignal, this, &DNVideoManager::onStopSeagrassCameraRecording);
    connect(newvideoitem, &VideoItem::sendMsg, _core->networkManager(), &NetworkManager::sendMsgbyID);

}

void DNVideoManager::onPlay(VideoItem* videoItem)
{
    QHostAddress ip = QHostAddress(_core->boatManager()->getBoatbyID(videoItem->boatID())->currentIP());
    char rawdata[9];

    uint8_t operation = 1;
    uint8_t videoInexraw = videoItem->videoNo();
    uint8_t formatIndexraw = videoItem->formatIndex();
    uint8_t encoder = videoItem->encoder() == QString("h264")? 0:1;
    int32_t port = videoItem->port();
    uint8_t aiEnabled = videoItem->AIEnabled();

    memcpy(rawdata, &operation, sizeof(uint8_t));
    memcpy(rawdata+1, &videoInexraw, sizeof(uint8_t));
    memcpy(rawdata+2, &formatIndexraw, sizeof(uint8_t));
    memcpy(rawdata+3, &encoder, sizeof(uint8_t));

    memcpy(rawdata+4, &port, sizeof(int32_t));
    memcpy(rawdata+8, &aiEnabled, sizeof(int8_t));
    QByteArray msg = QByteArray(rawdata,9);
    qDebug()<<"DNVideoManager::onPlay:"+QString::number(videoItem->port())+",send: "+msg;
    //if(msg == QString("")) return;
    emit sendMsg(ip, _core->configManager()->message("COMMAND"), msg);

}

void DNVideoManager::onStop(VideoItem* videoItem)
{

    if(videoItem->currentPlayingVideoIndex() == -1){
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

void DNVideoManager::onDetectMsg(uint8_t boatID, QByteArray detectMsg)
{
    uint8_t cmd_ID = uint8_t(detectMsg[0]);
    uint8_t video_no = uint8_t(detectMsg[1]);
    QStringList list;
    if(cmd_ID == 1){
        detectMsg.remove(0,2);
        for(int i = 0; i< videoList.size(); i++){
            if(videoList[i]->videoNo() == video_no){

                videoList[i]->processDetection(detectMsg);
            }
        }

    }
}



void DNVideoManager::onRequestFormat(VideoItem* videoItem)
{
    BoatItem* boat = _core->boatManager()->getBoatbyID(videoItem->boatID());
    if(boat == 0){
        qDebug()<<"**Fatal: DNVideoManager::onRequestFormat: boatID "<<videoItem->boatID()<<" not exist!";
        return;
    }
    QHostAddress addr(boat->currentIP());
    qDebug()<<"DNVideoManager::onRequestFormat: currentIP:"<<_core->boatManager()->getBoatbyID(videoItem->boatID())->currentIP();
    emit sendMsg(addr, _core->configManager()->message("FORMAT"), "");
}

void DNVideoManager::setVideoFormat(uint8_t ID, QByteArray data)
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

void DNVideoManager::connectionChanged(uint8_t ID)
{

    qDebug()<<"DNVideoManager::connectionChanged: "<<ID;
    /* 先不使用
    for(int i = 0; i < videoList.size(); i++){
        if(videoList[i]->boatID() == ID){
            if(videoList[i]->isPlaying()){
                videoList[i]->stop();
                videoList[i]->play(videoList[i]->videoIndex(), videoList[i]->qualityIndex());
            }

        }
    }
*/
}

void DNVideoManager::onSettingSeagrassCamera(VideoItem* videoItem)
{

    QString videoNo = QString("video")+QString::number(videoItem->videoNo());
    if(_core->boatManager()->getBoatbyID(videoItem->boatID()) == 0){
        qDebug()<<"\u001b[38;5;203m"<<"Fatal:: DNVideoManager::onStop, boat ID:"<< videoItem->boatID()<<" not exist"<<"\033[0m";
        return;
    }
    QHostAddress ip = QHostAddress(_core->boatManager()->getBoatbyID(videoItem->boatID())->currentIP());
    char rawdata[8];
    uint8_t operation = 0;
    uint8_t videoInexraw = videoItem->videoNo();
    uint8_t formatIndexraw = videoItem->formatIndex();
    uint8_t encoder = videoItem->encoder() == QString("h264")? 0:1;
    int32_t port = videoItem->port();

    memcpy(rawdata, &operation, sizeof(uint8_t));
    memcpy(rawdata+1, &videoInexraw, sizeof(uint8_t));
    memcpy(rawdata+2, &formatIndexraw, sizeof(uint8_t));
    memcpy(rawdata+3, &encoder, sizeof(uint8_t));
    memcpy(rawdata+4, &port, sizeof(int32_t));

    QByteArray msg = QByteArray(rawdata,8);
    qDebug()<<"DNVideoManager::onPlay:"+QString::number(videoItem->port())+",send: "+msg;
    //if(msg == QString("")) return;
    emit sendMsg(ip, _core->configManager()->message("SEAGRASS"), msg);

}

void DNVideoManager::onStartSeagrassCameraRecording(VideoItem* videoItem)
{

    if(_core->boatManager()->getBoatbyID(videoItem->boatID()) == 0){
        qDebug()<<"\u001b[38;5;203m"<<"Fatal:: DNVideoManager::onStop, boat ID:"<< videoItem->boatID()<<" not exist"<<"\033[0m";
        return;
    }
    QHostAddress ip = QHostAddress(_core->boatManager()->getBoatbyID(videoItem->boatID())->currentIP());
    char rawdata[1];
    uint8_t operation = 1;


    memcpy(rawdata, &operation, sizeof(uint8_t));


    QByteArray msg = QByteArray(rawdata,1);
    qDebug()<<"DNVideoManager::onStartRecording:"+QString::number(videoItem->port())+",send: "+msg;
    //if(msg == QString("")) return;
    emit sendMsg(ip, _core->configManager()->message("SEAGRASS"), msg);

}

void DNVideoManager::onStopSeagrassCameraRecording(VideoItem* videoItem)
{

    if(_core->boatManager()->getBoatbyID(videoItem->boatID()) == 0){
        qDebug()<<"\u001b[38;5;203m"<<"Fatal:: DNVideoManager::onStop, boat ID:"<< videoItem->boatID()<<" not exist"<<"\033[0m";
        return;
    }
    QHostAddress ip = QHostAddress(_core->boatManager()->getBoatbyID(videoItem->boatID())->currentIP());
    char rawdata[1];
    uint8_t operation = 2;


    memcpy(rawdata, &operation, sizeof(uint8_t));


    QByteArray msg = QByteArray(rawdata,1);
    qDebug()<<"DNVideoManager::onStopRecording:"+QString::number(videoItem->port())+",send: "+msg;
    //if(msg == QString("")) return;
    emit sendMsg(ip, _core->configManager()->message("SEAGRASS"), msg);

}
