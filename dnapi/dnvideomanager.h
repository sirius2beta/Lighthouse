#ifndef DNVIDEOMANAGER_H
#define DNVIDEOMANAGER_H

#include <QObject>
#include <QCoreApplication>
#include <QHostAddress>
#include <QQuickItem>
#include <QStringList>
#include <gst/gst.h>

#include "videoitem.h"



class DNCore;

class DNVideoManager : public QObject
{
    Q_OBJECT
public:

    explicit DNVideoManager(QObject *parent = nullptr, DNCore* core = nullptr);

    ~DNVideoManager();
    Q_PROPERTY(int count READ count NOTIFY coutChanged);

    Q_INVOKABLE VideoItem* getVideoItem(int index) { return videoList[index];}
    void init();
    void initVideo();
    void initGstreamer();
    void setVideoTest(QQuickItem* widget);
    void addVideoItem(int index, QString title, int boatID, int videoNo, int formatNo, int PCPort);

    int count() { return videoList.size();  }


public slots:
    void onPlay(VideoItem* videoItem);
    void onStop(VideoItem* videoItem);
    void onBoatAdded();
    void onRequestFormat(VideoItem* videoItem);
    void onDetectMsg(uint8_t boatID, QByteArray detectMsg);
    void setVideoFormat(uint8_t ID, QByteArray data);
    void connectionChanged(uint8_t ID);
    void onSettingSeagrassCamera(VideoItem* videoItem);
    void onStartSeagrassCameraRecording(VideoItem* videoItem);
    void onStopSeagrassCameraRecording(VideoItem* videoItem);
signals:
    void sendMsg(qint8 boatID, char topic, QByteArray command);
    void coutChanged(int count);

private:
    QVector<VideoItem*> videoList;
    DNCore* _core;
    GstElement *_testpipeline;
    GstElement *_testsink;


};

#endif // DNVIDEOMANAGER_H
