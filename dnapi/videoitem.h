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

class DNCore;
class VideoItem : public QObject
{
    Q_OBJECT
public:
    explicit VideoItem(QObject *parent = nullptr, DNCore* core = nullptr, int index=-1, QString title=QString(), int boatID=-1, int videoNo=-1, int formatNo=-1, int PCPort=0);
    ~VideoItem();
    Q_PROPERTY(QStringList videoNoListModel READ videoNoListModel NOTIFY videoNoListModelChanged)
    Q_PROPERTY(QStringList qualityListModel READ qualityListModel NOTIFY qualityListModelChanged)
    Q_PROPERTY(QStringList formatListStringModel READ formatListStringModel NOTIFY formatListStringModelChanged)
    Q_PROPERTY(QList<int> detectionMatrixModel READ detectionMatrixModel NOTIFY detectionMatrixModelChanged)

    Q_PROPERTY(int boatID READ boatID NOTIFY boatIDChanged )
    Q_PROPERTY(int videoNo READ videoNo CONSTANT)
    Q_PROPERTY(int formatNo READ formatNo CONSTANT)
    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(int PCPort READ PCPort NOTIFY PCPortChanged)
    Q_PROPERTY(bool AIEnabled READ AIEnabled CONSTANT)
    //Q_PROPERTY(QString port READ port NOTIFY IPChanged)
    //Q_PROPERTY(bool primaryConnected READ primaryConnected  NOTIFY connectStatusChanged)
    //Q_PROPERTY(bool secondaryConnected READ secondaryConnected  NOTIFY connectStatusChanged)


    Q_INVOKABLE void play();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void setAIEnabled(bool enabled);
    Q_INVOKABLE void update(); // update camera info

    Q_INVOKABLE void setProxy(bool isProxy);
    Q_INVOKABLE void setEncoder(QString encoder);
    Q_INVOKABLE void setTitle(QString title);
    Q_INVOKABLE void setPCPort(int port);
    Q_INVOKABLE void setBoatID(int ID);
    Q_INVOKABLE void setIndex(int index);
    Q_INVOKABLE void setVideoIndex(int index);
    Q_INVOKABLE void setFormatNo(int no);
    Q_INVOKABLE void setProxyMode(bool p){ _proxyMode = p;}

    void initVideo(QQuickItem *widget);
    void setDisplay(WId xwinid);
    void setVideoFormat(QByteArray data);
    void setWID(WId wid){_xwinid = wid;}
    void setConnectionPriority(int connectionType);
    void setVideoInfo(bool i) { _isVideoInfo = i; }

    QString title() { return _title;   }
    int boatID() {  return _boatID; }
    int PCPort() {  return _PCPort; }
    int port() {return _proxy?(_PCPort+100):_PCPort;}
    int index() {return _index; }
    int videoNo() {
        if(_videoIndex == -1){
            return -1;
        }else{
            return _videoNoListModel[_videoIndex].toInt();
        }
    }
    int formatIndex() { return _formatListModel[_formatNo].toInt();}
    int formatNo() {    return _formatNo; }
    bool isPlaying(){ return _isPlaying;}
    int connectionPriority() { return _connectionPriority;}
    bool videoInfo() { return _isVideoInfo; }
    bool AIEnabled() { return _AIEnabled;}
    QStringList videoNoListModel() { return _videoNoListModel; }
    QStringList qualityListModel() { return _formatListModel; }
    QStringList formatListStringModel() {return _formatStringListModel; }
    QList<int> detectionMatrixModel() { return _detectionMatrixModel;}



    QString encoder() {return _encoder;}
    QString videoFormat();
    void proscessDetection(QByteArray data);

signals:
    void sendMsg(int8_t boatID, char topic, QByteArray data);
    void requestFormat(VideoItem* v); //set _requestFormat = true before sending
    void boatIDChanged(int ID);
    void PCPortChanged(int port);
    void titleChanged(QString title);
    void indexChanged(int index);
    void videoPlayed(VideoItem* v);
    void videoStoped(VideoItem* v);
    void videoNoListModelChanged(QStringList model);
    void qualityListModelChanged(QStringList model);
    void formatListStringModelChanged(QStringList model);
    void detectionMatrixModelChanged(QList<int> model);


private:
    DNCore* _core;
    bool _initialized;
    QString _title;
    int _boatID;
    int _index;
    int _videoIndex;
    int _preVideoIndex;
    int _formatNo;
    int _PCPort;
    int _connectionPriority;
    WId _xwinid;
    QString _encoder;
    bool _proxy;
    bool _requestFormat;
    bool _AIEnabled;
    QQuickItem* _videoWidget;

    GstElement *_pipeline;
    GstElement *_sink;
    bool _isPlaying;
    bool _isVideoInfo;

    bool _proxyMode;
    QMap<int, QList<int>> _videoFormatList;

    QStringList _videoNoListModel;
    QStringList _formatListModel;
    QStringList _formatStringListModel;
    QList<int> _detectionMatrixModel;

};

#endif // VIDEOITEM_H
