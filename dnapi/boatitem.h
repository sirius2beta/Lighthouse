#ifndef BOATITEM_H
#define BOATITEM_H

#include <QObject>
#include <QElapsedTimer>
#include "device.h"

class DNCore;
class BoatItem : public QObject
{
    Q_OBJECT
public:
    explicit BoatItem(QObject *parent = nullptr, DNCore* core = nullptr);
    BoatItem(const BoatItem& other, QObject* parent = nullptr);
    const BoatItem& operator=(const BoatItem& other);

    ~BoatItem();

    Q_PROPERTY(int ID READ ID CONSTANT)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString PIP READ PIP WRITE setPIP NOTIFY PIPChanged)
    Q_PROPERTY(QString SIP READ SIP WRITE setSIP NOTIFY SIPChanged)
    Q_PROPERTY(bool primaryConnected READ primaryConnected  NOTIFY connectionStatusChanged)
    Q_PROPERTY(bool secondaryConnected READ secondaryConnected  NOTIFY connectionStatusChanged)
    Q_PROPERTY(QStringList deviceStatusCode READ deviceStatusCode NOTIFY deviceStatusCodeChanged)


    QString name(void) {    return _name;   };
    int ID(void) {    return _ID; };
    QString PIP(void) {    return _PIP;    };
    QString SIP(void) {    return _SIP;    };
    QString currentIP(void) {
        return _currentIP;
    };
    int OS(void) {    return _OS;   };
    int linkType() { return _linkType; }
    bool primaryConnected() { return _primaryConnected;}
    bool secondaryConnected() { return _secondaryConnected;}


    void setName(QString name);
    void setID(int ID);
    void setPIP(QString PIP);
    void setSIP(QString SIP);
    void setOS(int OS);
    void setConnectionPriority(int connectionType);


    Device* getDevbyID(int ID);
    Peripheral getPeriperalbyID(int ID);
    void connect(bool isPrimary);
    void disconnect(bool isPrimary);

    QStringList deviceStatusCode() { return _deviceStatusCode; }
    void setDeviceStatusCode(QStringList list);
    Q_INVOKABLE void restartService();
    Q_INVOKABLE void reboot();
    Q_INVOKABLE void stopService();
    Q_INVOKABLE void update();
    QList<Peripheral> peripherals;
    QList<Device> devices;
    void receivedMsg(bool isPrimary);
signals:
    void nameChanged(int ID, QString name);
    void PIPChanged(const QString& IP); // for qml
    void SIPChanged(const QString& IP); //for qml
    void IDChanged(int ID);
    void IPChanged(const int& ID, bool isPrimary);
    void connectionStatusChanged(); // for qml
    void connectionChanged(int ID); // notify videomanager to switch connection
    void deviceStatusCodeChanged(QStringList model);
    void restartServiceSignal(uint8_t boatID);
    void rebootSignal(uint8_t boatID);
    void stopServiceSignal(uint8_t boatID);
    void updateSignal(uint8_t boatID);

protected slots:
    void onDeviceStatusMsg(uint8_t boatID, QByteArray detectMsg);
    void _commLostCheck();

    //void onIPChanged(const QString& IP);
private:

    static constexpr int _heartbeatTimeoutMSecs = 1000; ///< Check for comm lost once a second
    static constexpr int _commLostCheckTimeoutMSecs = 1000; ///< Check for comm lost once a second
    static constexpr int _heartbeatMaxElpasedMSecs = 3500;  ///< No heartbeat for longer than this indicates comm loss

    DNCore* _core;
    QString _name = QString("null");
    int _ID;
    QString _PIP;
    QString _SIP;
    QString _currentIP;
    int _OS;
    bool _primaryConnected;
    bool _secondaryConnected;
    int _connectionPriority;
    int _linkType;
    QStringList _deviceStatusCode;




    struct LinkInfo_t {
        bool commLost = false;
        QElapsedTimer heartbeatElapsedTimer;
    };
    LinkInfo_t _primaryUdpLinkInfo;
    LinkInfo_t _secondaryUdpLinkInfo;

    QTimer *_commLostCheckTimer = nullptr;
    bool _updatePrimaryLink();


};

#endif // BOATITEM_H
