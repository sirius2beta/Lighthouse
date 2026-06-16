#ifndef VIDEOITEM_H
#define VIDEOITEM_H

#include <QObject>
#include <gst/gst.h>
#include <gst/video/videooverlay.h>
#include <QWidget>
#include <QStandardItemModel>
#include <QQuickWindow>
#include <QQuickItem>
#include <QMap>
#include <QHostAddress>
#include <QtCore/QMutex>
#include <QtCore/QQueue>
#include <QtCore/QThread>
#include <QtCore/QTimer>
#include <QtCore/QWaitCondition>
class DNCore;

typedef std::function<void()> Task;


class GstVideoWorker : public QThread
{
    Q_OBJECT

public:
    explicit GstVideoWorker(QObject *parent = nullptr);
    ~GstVideoWorker();
    bool needDispatch() const;
    void dispatch(Task task);
    void shutdown();

private:
    void run() final;

    QWaitCondition _taskQueueUpdate;
    QMutex _taskQueueSync;
    QQueue<Task> _taskQueue;
    bool _shutdown = false;
};

class VideoItem : public QObject
{
    Q_OBJECT
public:
    explicit VideoItem(QObject *parent = nullptr, DNCore* core = nullptr, int index=-1, QString title=QString(), int boatID=-1, int videoNo=-1, int qualityIndex=-1, int PCPort=0);
    ~VideoItem();
    Q_PROPERTY(QStringList videoNoListModel READ videoNoListModel NOTIFY videoNoListModelChanged)
    Q_PROPERTY(QStringList qualityListModel READ qualityListModel NOTIFY qualityListModelChanged)
    Q_PROPERTY(QStringList formatListStringModel READ formatListStringModel NOTIFY formatListStringModelChanged)
    Q_PROPERTY(QList<int> detectionMatrixModel READ detectionMatrixModel NOTIFY detectionMatrixModelChanged)

    Q_PROPERTY(int boatID READ boatID NOTIFY boatIDChanged )
    Q_PROPERTY(int videoIndex READ videoIndex NOTIFY videoIndexChanged)
    Q_PROPERTY(int videoNo READ videoNo CONSTANT)
    Q_PROPERTY(int qualityIndex READ qualityIndex NOTIFY qualityIndexChanged)
    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(int PCPort READ PCPort NOTIFY PCPortChanged)
    Q_PROPERTY(bool AIEnabled READ AIEnabled CONSTANT)
    Q_PROPERTY(uint8_t AIType READ AIType NOTIFY aiTypeChanged)
    Q_PROPERTY(uint8_t status READ status NOTIFY statusChanged)
    Q_PROPERTY(uint8_t recording READ recording NOTIFY recordingChanged)
    Q_PROPERTY(int blockID READ blockID CONSTANT)
    //Q_PROPERTY(QString port READ port NOTIFY IPChanged)
    //Q_PROPERTY(bool primaryConnected READ primaryConnected  NOTIFY connectStatusChanged)
    //Q_PROPERTY(bool secondaryConnected READ secondaryConnected  NOTIFY connectStatusChanged)


    Q_INVOKABLE void play(int videoIndex, int qualityIndex, uint8_t aitype);
    Q_INVOKABLE void stop();
    Q_INVOKABLE void setAIEnabled(bool enabled);
    Q_INVOKABLE void setAIType(uint8_t type);
    Q_INVOKABLE void update(); // update camera info
    Q_INVOKABLE void setAsSeagrassCamera(int videoIndex, int qualityIndex);
    Q_INVOKABLE void startSeagrassCameraRecording();
    Q_INVOKABLE void stopSeagrassCameraRecording();
    Q_INVOKABLE void getVideoStatus(uint8_t videoIndex);

    Q_INVOKABLE void setProxy(bool isProxy);
    Q_INVOKABLE void setEncoder(QString encoder);
    Q_INVOKABLE void setTitle(QString title);
    Q_INVOKABLE void setPCPort(int port);
    Q_INVOKABLE void setBoatID(int ID);
    Q_INVOKABLE void setIndex(int index);
    Q_INVOKABLE void setVideoIndex(int index);
    Q_INVOKABLE void setQualityIndex(int index);
    Q_INVOKABLE void setProxyMode(bool p){ _proxyMode = p;}
    Q_INVOKABLE void setBlockID(int ID) { _blockID = ID;}; // update camera info
    Q_INVOKABLE void getVideoFormatByIndex(int index);

    void initVideo(QQuickItem *widget);
    void start();
    void stopPipeline();
    void cleanGstreamer();
    void setDisplay(WId xwinid);
    void setVideoFormat(QByteArray data);
    void setVideoStatus(QByteArray data);
    void setCurrentVideoStatus(QByteArray data);
    void setWID(WId wid){_xwinid = wid;}
    void setConnectionPriority(int connectionType);
    void setVideoInfo(bool i) { _isVideoInfo = i; }

    QString title() { return _title;   }
    int boatID() {  return _boatID; }
    int PCPort() {  return _PCPort; }
    int port() {return _proxy?(_PCPort+100):_PCPort;}
    int index() {return _index; }
    int currentPlayingVideoIndex() {return _currentPlayingVideoIndex;}
    int videoIndex() { return _videoIndex;}
    int videoNo() {
        if(_videoIndex == -1){
            return -1;
        }else{
            if(_videoIndex>=_videoNoListModel.size()){
                return -1;
            }
            return _videoNoListModel[_videoIndex].toInt();
        }
    }
    int formatIndex() { return _formatListModel[_qualityIndex].toInt();}
    int qualityIndex() {    return _qualityIndex; }
    bool isPlaying(){ return _isPlaying;}
    int connectionPriority() { return _connectionPriority;}
    bool videoInfo() { return _isVideoInfo; }
    bool AIEnabled() { return _AIEnabled;}
    uint8_t AIType() {  return _AIType;}
    uint8_t status() {  return _status;}
    uint8_t recording() {   return _recording;}
    QStringList videoNoListModel() { return _videoNoListModel; }
    QStringList qualityListModel() { return _formatListModel; }
    QStringList formatListStringModel() {return _formatStringListModel; }
    QList<int> detectionMatrixModel() { return _detectionMatrixModel;}
    int blockID() { return _blockID; }


    QString encoder() {return _encoder;}
    QString videoFormat();
    void processDetection(QByteArray data);
    void setAIModelReady(uint8_t model_index, uint8_t isReady);
    bool _needDispatch();
    enum VIDEO_STREAM_TYPE {
        VIDEO_STREAM_TYPE_RTPUDP = 0,
        VIDEO_STREAM_TYPE_RTSP
    };
    Q_ENUM(VIDEO_STREAM_TYPE)

    enum STATUS {
            STATUS_MIN = 0,
            STATUS_OK = STATUS_MIN,
            STATUS_FAIL,
            STATUS_INVALID_STATE,
            STATUS_INVALID_URL,
            STATUS_NOT_IMPLEMENTED,
            STATUS_MAX = STATUS_NOT_IMPLEMENTED
        };
        Q_ENUM(STATUS)
        static bool isValidStatus(STATUS status) { return ((status >= STATUS_MIN) && (status <= STATUS_MAX)); }
signals:
    void sendMsg(int8_t boatID, char topic, QByteArray data);
    void requestFormat(VideoItem* v); //set _requestFormat = true before sending
    void boatIDChanged(int ID);
    void PCPortChanged(int port);
    void titleChanged(QString title);
    void indexChanged(int index);
    void qualityIndexChanged(int qualityIndex);
    void aiTypeChanged(int type);
    void videoPlayed(VideoItem* v);
    void videoStoped(VideoItem* v);
    void videoNoListModelChanged(QStringList model);
    void qualityListModelChanged(QStringList model);
    void formatListStringModelChanged(QStringList model);
    void detectionMatrixModelChanged(QList<int> model);
    void setAsSeagrassCameraSignal(VideoItem* v);
    void startSeagrassCameraRecordingSignal(VideoItem* v);
    void stopSeagrassCameraRecordingSignal(VideoItem* v);
    void videoIndexChanged(uint8_t index);
    void statusChanged(uint8_t status);
    void recordingChanged(uint8_t recording);
    void modelReady(uint8_t index, uint8_t isReady);
    void seagrassModelReady(uint8_t isReady);
    void onStartComplete(STATUS status);
    void onStopComplete(STATUS status);

public slots:
    void onCameraMsg(uint8_t boatID, QByteArray msg);
    void handlePipelineError();
    void watchdogCheck(); // 看門狗定時檢查

private:
    DNCore* _core;
    QString _title;
    int _boatID;
    int _index;
    int _videoIndex;
    int _currentPlayingVideoIndex;
    int _prePlayingVideoIndex;
    int _qualityIndex;
    int _PCPort;
    int _connectionPriority;
    int _blockID;
    WId _xwinid;
    QString _encoder;
    bool _proxy;
    bool _requestFormat;
    bool _AIEnabled;
    uint8_t _AIType;
    uint8_t _recording;
    uint8_t _status;
    QQuickItem* _videoWidget;

    GstElement *_pipeline = nullptr;
    GstElement *_sink = nullptr;
    bool _isPlaying;
    bool _isVideoInfo;

    bool _proxyMode;
    QMap<int, QList<int>> _videoFormatList;

    QStringList _videoNoListModel;
    QStringList _formatListModel;
    QStringList _formatStringListModel;
    QList<int> _detectionMatrixModel;
    GstVideoWorker *_worker = nullptr;

    qint64 _lastFrameTime = 0;
    QTimer* _reconnectTimer;
    QTimer _watchdogTimer;

        // GStreamer 探針回呼函式
    static GstPadProbeReturn padProbeCb(GstPad *pad, GstPadProbeInfo *info, gpointer user_data);

    uint32_t _signalDepth = 0;
    void _dispatchSignal(Task emitter);
    VIDEO_STREAM_TYPE _streamType;

};


#endif // VIDEOITEM_H
