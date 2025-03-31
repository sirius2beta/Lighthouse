//#include "dnapplication.h"
#include "dncore.h"
#include "videoitem.h"
#include <QDebug>
#include <QQuickWindow>
#include <QQuickItem>
#include <QQmlEngine>



VideoItem::VideoItem(QObject *parent, DNCore* core, int index, QString title, int boatID, int videoNo, int formatNo, int PCPort)
    : QObject{parent},
      _core(core),
      _initialized(false),
      _title(title),
      _boatID(boatID),
      _index(index),
    _videoIndex(videoNo),
    _preVideoIndex(-1),
    _formatNo(formatNo),
    _PCPort(PCPort),
    _connectionPriority(0),
    _encoder(QString("h264")),
    _proxy(false),
    _requestFormat(true),
    _isPlaying(false),
    _isVideoInfo(false),
    _AIEnabled(false)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);


}

VideoItem::~VideoItem()
{

    if(_initialized == false){

    }else{
        gst_element_set_state (_pipeline, GST_STATE_NULL);
        gst_object_unref (_pipeline);
        gst_object_unref (_sink);
    }
}

void VideoItem::initVideo(QQuickItem *widget)
{
    _videoWidget = widget;

    QString gstcmd;
     if(_encoder == "h264"){
         gstcmd = QString("udpsrc port=%1 ! application/x-rtp, media=video, clock-rate=90000, payload=96 ! rtph264depay ! avdec_h264 ! videoconvert  !\
          glupload ! glcolorconvert ! qml6glsink name=sink").arg(QString::number(_PCPort));
     }else{
          gstcmd = QString("udpsrc port=%1 ! application/x-rtp, media=video, clock-rate=90000, payload=96 ! rtpjpegdepay ! jpegdec ! videoconvert  !\
          glupload ! qml6glsink name=sink").arg(QString::number(_PCPort));
     }

    if(!_initialized){
        _pipeline= gst_parse_launch(gstcmd.toLocal8Bit(), NULL);
        _sink = gst_bin_get_by_name((GstBin*)_pipeline,"sink");
        g_object_set(_sink, "widget", widget, NULL);
        gst_element_set_state (_pipeline, GST_STATE_PLAYING);

    }

    _initialized = true;
}

void VideoItem::setTitle(QString title)
{
    _title = title;
    emit titleChanged(title);
}

void VideoItem::setPCPort(int port)
{
    _PCPort = port;
    emit PCPortChanged(port);
}

void VideoItem::setBoatID(int ID)
{

    if(_core->boatManager()->getBoatbyID(ID) == 0){
        qDebug()<<"**Fatal:: VideoItem::setBoatID: ID out of range";
        return;
    }

    if(_boatID != ID){
        stop();
        //new list model
        _videoNoListModel.clear();
        _formatListModel.clear();
        _formatStringListModel.clear();
        emit videoNoListModelChanged(_videoNoListModel);
        emit qualityListModelChanged(_formatListModel);
        emit formatListStringModelChanged(_formatStringListModel);

        _boatID = ID;
        _requestFormat = true;
        _preVideoIndex = -1;
        emit requestFormat(this);

    }
}

void VideoItem::setIndex(int index)
{
    _index = index;
    emit indexChanged(index);
}

void VideoItem::setVideoIndex(int index)
{
    if(index >= _videoNoListModel.size()){
        qDebug()<<"**Fatal:: VideoItem::setVideoNo: index out of range";
        return;
    }
    _videoIndex = index;
    _formatListModel.clear();
    _formatStringListModel.clear();

    QList<int> h = _videoFormatList[_videoNoListModel.at(index).toInt()];
    for(int i = 0; i< h.size(); i++){
        _formatListModel<<QString::number(h[i]);
        _formatStringListModel<<_core->configManager()->videoFormatString(h[i]);
    }
    if(_formatListModel.size() > 0){
        _formatNo = 0;
    }
    emit qualityListModelChanged(_formatListModel);
    emit formatListStringModelChanged(_formatStringListModel);
}

void VideoItem::setVideoFormat(QByteArray data)
{
    if(!_requestFormat) return;
    _requestFormat = false;
    QString currentvideoNo = QString();
    qDebug()<<" VideoItem::setVideoNo: got videoFormat";
    _videoFormatList.clear();
    int videoNo;
    int formatNo;
    int readorder = 0;
    if(data.size()%2 != 0 || data.size()/2 == 0){
        qDebug()<<"**Fatal::VideoItem::setVideoNo: wrong format message:"<<data.size();
        return;
    }
    for(int i = 0; i < data.size(); i+=2){
        videoNo = int(data[i]);
        formatNo = int(data[i+1]);
        _videoFormatList[videoNo].append(formatNo);
    }

    QMap<int, QList<int>>::const_iterator h = _videoFormatList.constBegin();
    while(h != _videoFormatList.constEnd()){
        _videoNoListModel<<QString::number(h.key());
        emit videoNoListModelChanged(_videoNoListModel);
        ++h;
    }

    if(_videoNoListModel.size() >0){
        setVideoIndex(0);
    }
}

void VideoItem::setFormatNo(int no)
{
    if(no >= _formatListModel.size()){
        qDebug()<<"**Fatal:: VideoItem::setFormatNo: index out of range";
        return;
    }
    _formatNo = no;
}

void VideoItem::setDisplay(WId xwinid)
{
    _xwinid = xwinid;
}

void VideoItem::setConnectionPriority(int connectionType)
{
    qDebug()<<"VideoItem:: connectionTypeChanged: index:"<<_index<<", pre:"<<_connectionPriority<<", now:"<<connectionType;
    qDebug()<<"isPlaying:"<<(_isPlaying?"yes":"no");
    if(_connectionPriority != connectionType){
        _connectionPriority = connectionType;
        if(_isPlaying){
            qDebug()<<"VideoItem:: connectionTypeChanged:STOP & PLAY";
            stop();
            play();
        }else{
        }
    }

}

void VideoItem::play()
{
    //QSound::play(":/imports/DenovoUI/images/79.wav");
    qDebug()<<"VideoItem::play, videoIndex:"<<_videoIndex<<", formatNo:"<<_formatNo;
    if(_boatID == -1 || _videoIndex == -1 || _formatNo == -1) return;
    int tempIndex = _videoIndex;
    if(_isPlaying && _preVideoIndex!=-1){
        _videoIndex = _preVideoIndex;
        stop();
    }
    _videoIndex =tempIndex;
    _preVideoIndex = _videoIndex;
    _isPlaying = true;
    emit videoPlayed(this);
}

void VideoItem::stop()
{   
    if(_isPlaying){
        _isPlaying = false;
        emit videoStoped(this);
    }

}

void VideoItem::setAIEnabled(bool enabled)
{
    qDebug()<<"setAIEnabled:"<<enabled;
    QByteArray bt;
    //uint8_t video_no = _videoIndex;
    //bt.append(boatID());
    uint8_t cmd_ID = 0;
    bt.append(cmd_ID);
    bt.append(uint8_t(videoNo()));
    bt.append(enabled);
    bt.append(uint8_t(_formatNo));
    _AIEnabled = enabled;
    //emit sendMsg(boatID(), 6, bt);
}

void VideoItem::update()
{
    stop();
    //new list model
    _videoNoListModel.clear();
    _formatListModel.clear();
    _formatStringListModel.clear();
    emit videoNoListModelChanged(_videoNoListModel);
    emit qualityListModelChanged(_formatListModel);
    emit formatListStringModelChanged(_formatStringListModel);

    _requestFormat = true;
    _preVideoIndex = -1;
    emit requestFormat(this);
}

void VideoItem::setProxy(bool isProxy)
{
    _proxy = isProxy;

}

void VideoItem::setEncoder(QString encoder)
{
    if(_encoder != encoder){
        _encoder = encoder;
        QString gstcmd;

        if(_encoder == "h264"){
            gstcmd = QString("udpsrc port=%1 ! application/x-rtp, media=video, clock-rate=90000, payload=96 ! rtph264depay ! avdec_h264 ! videoconvert  !\
             qml6glsink name=mySink2").arg(QString::number(_PCPort));
        }else{
             gstcmd = QString("udpsrc port=%1 ! application/x-rtp, media=video, clock-rate=90000, payload=96 ! rtpjpegdepay ! jpegdec ! videoconvert  !\
             qml6glsink name=mySink2").arg(QString::number(_PCPort));
        }
        gst_element_set_state (_pipeline, GST_STATE_NULL);

        _pipeline= gst_parse_launch(gstcmd.toLocal8Bit(), NULL);
        _sink = gst_bin_get_by_name((GstBin*)_pipeline,"mySink2");
        gst_video_overlay_set_window_handle (GST_VIDEO_OVERLAY (_sink), _xwinid);
        gst_element_set_state (_pipeline,
            GST_STATE_PLAYING);

        if(_videoWidget != nullptr){
            g_object_set(_sink, "widget", _videoWidget, NULL);
        }
    }
}

QString VideoItem::videoFormat()
{
    if(_formatNo == -1){
        qDebug()<<"**Warning: VideoItem::videoFormat: _formatNo = -1";
        return QString("");
    }
    return _formatListModel[_formatNo];

}

void VideoItem::proscessDetection(QByteArray data)
{
    _detectionMatrixModel.clear();



    for(int i = 0; i< data.size(); ){
        if(i%17==0){
            uint8_t x;
            memcpy(&x, data.data()+i, sizeof(uint8_t));
            _detectionMatrixModel.append(x);
           // qDebug()<<"class:"<< x;
            i += 1;
        }else if(i%17==9){
            float x;
            float y;
            memcpy(&x, data.data()+i, sizeof(float));
            _detectionMatrixModel.append(x*100);
            memcpy(&y, data.data()+i+4, sizeof(float));
            _detectionMatrixModel.append(y*100);
            i+=8;

        }else{
            uint16_t x;
            memcpy(&x, data.data()+i, sizeof(uint16_t));
            _detectionMatrixModel.append(x);
            i += 2;
        }


    }
    emit detectionMatrixModelChanged(_detectionMatrixModel);
}
