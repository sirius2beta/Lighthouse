//#include "dnapplication.h"
#include "dncore.h"
#include "videoitem.h"
#include <QDebug>
#include <QQuickWindow>
#include <QQuickItem>
#include <QQmlEngine>



VideoItem::VideoItem(QObject *parent, DNCore* core, int index, QString title, int boatID, int videoNo, int qualityIndex, int PCPort)
    : QObject{parent},
      _core(core),
      _initialized(false),
      _title(title),
      _boatID(boatID),
      _index(index),
    _videoIndex(videoNo),
    _currentPlayingVideoIndex(-1),
    _prePlayingVideoIndex(-1),
    _qualityIndex(qualityIndex),
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
    connect(_core->networkManager(), &NetworkManager::cameraMsg, this, &VideoItem::onCameraMsg);


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
    //setenv("GST_DEBUG", "3,decodebin*:6,amc*:6,avdec*:6", 1);

    GstElement *decoder = gst_element_factory_make("decodebin3", nullptr);
    if (!decoder) {
        qDebug() << "gst_element_factory_make('decodebin3') failed";
    }
    GstElement *sink = nullptr;
    sink = gst_element_factory_make("qml6glsink", nullptr);
    if (!sink) {
        qDebug() << "gst_element_factory_make('qml6glsink') failed";
    }
    _videoWidget = widget;

    QString gstcmd;
     if(_encoder == "h264"){
# ifdef ANDROID
        gstcmd = QString(
                     "udpsrc port=%1 ! "
                     "application/x-rtp, media=video, clock-rate=90000, payload=96 ! "
                     "rtpjitterbuffer mode=1 latency=200 ! "
                     "rtph264depay ! h264parse ! "
                     "amcviddec-c2exynosh264decoder ! "
                     "queue max-size-buffers=1 leaky=downstream ! " // 修正為 leaky=downstream (或 leaky=1)
                     "glupload ! "
                     "glcolorconvert ! "
                     "qml6glsink name=sink sync=false async=false "
                     ).arg(QString::number(_PCPort));
#else
         gstcmd = QString("udpsrc port=%1 ! application/x-rtp, media=video, clock-rate=90000, payload=96 ! rtph264depay ! avdec_h264   !\
          glupload ! glcolorconvert ! qml6glsink name=sink").arg(QString::number(_PCPort));
#endif
     }else{
          gstcmd = QString("udpsrc port=%1 ! application/x-rtp, media=video, clock-rate=90000, payload=96 ! rtpjpegdepay ! jpegdec ! videoconvert  !\
          glupload ! qml6glsink name=sink").arg(QString::number(_PCPort));
     }

    if(!_initialized){
         GError *error = nullptr;
         // 1. 修正元件名稱為 qml6glsink 並增加錯誤捕捉
         _pipeline = gst_parse_launch(gstcmd.toLocal8Bit(), &error);

         if (error) {
             qDebug() << "Pipeline 啟動失敗:" << error->message;
             g_error_free(error);
             return;
         }

         if (!_pipeline) {
             qDebug() << "無法建立 Pipeline，請檢查 GStreamer 插件是否安裝完整。";
             return;
         }

         _sink = gst_bin_get_by_name(GST_BIN(_pipeline), "sink");

         if (!_sink) {
             qDebug() << "找不到名為 'sink' 的元件！";
         } else {
             // 2. 修正 g_object_set 的 Sentinel
             g_object_set(_sink, "widget", widget, NULL);
         }

         gst_element_set_state(_pipeline, GST_STATE_PLAYING);

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
        _prePlayingVideoIndex = -1;
        _currentPlayingVideoIndex = -1;
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
        _qualityIndex = 0;
    }
    emit qualityListModelChanged(_formatListModel);
    emit formatListStringModelChanged(_formatStringListModel);
}

void VideoItem::getVideoFormatByIndex(int index)
{
    if(index >= _videoNoListModel.size()){
        qDebug()<<"**Fatal:: VideoItem::setVideoNo: index out of range";
        return;
    }
    _formatListModel.clear();
    _formatStringListModel.clear();

    QList<int> h = _videoFormatList[_videoNoListModel.at(index).toInt()];
    for(int i = 0; i< h.size(); i++){
        _formatListModel<<QString::number(h[i]);
        _formatStringListModel<<_core->configManager()->videoFormatString(h[i]);
    }
    if(_formatListModel.size() > 0){
        _qualityIndex = 0;
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
    int qualityIndex;
    int readorder = 0;
    if(data.size()%2 != 0 || data.size()/2 == 0){
        qDebug()<<"**Fatal::VideoItem::setVideoNo: wrong format message:"<<data.size();
        return;
    }
    for(int i = 0; i < data.size(); i+=2){
        videoNo = int(data[i]);
        qualityIndex = int(data[i+1]);
        _videoFormatList[videoNo].append(qualityIndex);
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

void VideoItem::setQualityIndex(int no)
{
    if(no >= _formatListModel.size()){
        qDebug()<<"**Fatal:: VideoItem::setQualityIndex: index out of range";
        return;
    }
    _qualityIndex = no;
    emit qualityIndexChanged(_qualityIndex);
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
            play(_currentPlayingVideoIndex, _qualityIndex);
        }else{
        }
    }

}

void VideoItem::play(int videoIndex, int qualityIndex)
{
    //QSound::play(":/imports/DenovoUI/images/79.wav");
    qDebug()<<"VideoItem::play, videoIndex:"<<videoIndex<<", qualityIndex:"<<qualityIndex;
    if(_boatID == -1 || videoIndex == -1 || qualityIndex == -1) return;
    if(videoIndex >= _videoNoListModel.size()){
        qDebug()<<"**Fatal:: VideoItem::setVideoNo: index out of range";
        return;
    }
    if(qualityIndex >= _formatListModel.size()){
        qDebug()<<"**Fatal:: VideoItem::setQualityIndex: index out of range";
        return;
    }
    _videoIndex = videoIndex;
    _qualityIndex = qualityIndex;
    int tempIndex = _videoIndex;
    if(_isPlaying && _prePlayingVideoIndex!=-1){
        _prePlayingVideoIndex = _currentPlayingVideoIndex;
        stop();
    }
    _videoIndex =tempIndex;
    _currentPlayingVideoIndex = _videoIndex;
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
    bt.append(uint8_t(_videoIndex));
    bt.append(enabled);
    bt.append(uint8_t(_qualityIndex));
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
    _prePlayingVideoIndex = -1;
    emit requestFormat(this);
}

void VideoItem::setAsSeagrassCamera(int videoIndex, int qualityIndex)
{

    qDebug()<<"VideoItem::play, videoIndex:"<<videoIndex<<", qualityIndex:"<<qualityIndex;
    if(_boatID == -1 || videoIndex == -1 || qualityIndex == -1) return;
    if(videoIndex >= _videoNoListModel.size()){
        qDebug()<<"**Fatal:: VideoItem::setVideoNo: index out of range";
        return;
    }
    if(qualityIndex >= _formatListModel.size()){
        qDebug()<<"**Fatal:: VideoItem::setQualityIndex: index out of range";
        return;
    }
    _videoIndex = videoIndex;
    _qualityIndex = qualityIndex;
    int tempIndex = _videoIndex;
    if(_isPlaying && _prePlayingVideoIndex!=-1){
        _prePlayingVideoIndex = _currentPlayingVideoIndex;
        stop();
    }
    _videoIndex =tempIndex;
    _currentPlayingVideoIndex = _videoIndex;
    _isPlaying = true;
    emit setAsSeagrassCameraSignal(this);
}

void VideoItem::startSeagrassCameraRecording()
{
    emit startSeagrassCameraRecordingSignal(this);
}

void VideoItem::stopSeagrassCameraRecording()
{
    emit stopSeagrassCameraRecordingSignal(this);
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
            // 使用 decodebin 自動選取硬體解碼器 (MediaCodec)
            gstcmd = QString("udpsrc port=%1 ! application/x-rtp, media=video, clock-rate=90000, payload=96 ! "
                             "rtph264depay ! decodebin ! videoconvert ! "
                             "qml6glsink name=mySink2").arg(_PCPort);
        } else {
            gstcmd = QString("udpsrc port=%1 ! application/x-rtp, media=video, clock-rate=90000, payload=96 ! "
                             "rtpjpegdepay ! decodebin ! videoconvert ! "
                             "qml6glsink name=mySink2").arg(_PCPort);
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
    if(_qualityIndex == -1){
        qDebug()<<"**Warning: VideoItem::videoFormat: _qualityIndex = -1";
        return QString("");
    }
    return _formatListModel[_qualityIndex];

}

void VideoItem::processDetection(QByteArray data)
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

void VideoItem::onCameraMsg(uint8_t boatID, QByteArray msg)
{
    qDebug()<<"VideoItem::onCameraMsg videoItem index:"<<_index<<" , boatID:"<<boatID<<" , _boatID:"<<_boatID;
    if(boatID == _boatID){


    }
}
