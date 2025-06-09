#ifndef BOATITEM_H
#define BOATITEM_H

#include <QObject>
#include "device.h"

class HeartBeat;

class BoatItem : public QObject
{
    Q_OBJECT
public:
    explicit BoatItem(QObject *parent = nullptr);
    BoatItem(const BoatItem& other, QObject* parent = nullptr);
    const BoatItem& operator=(const BoatItem& other);

    ~BoatItem();

    Q_PROPERTY(int ID READ ID CONSTANT)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString PIP READ PIP WRITE setPIP NOTIFY PIPChanged)
    Q_PROPERTY(QString SIP READ SIP WRITE setSIP NOTIFY SIPChanged)
    Q_PROPERTY(bool primaryConnected READ primaryConnected  NOTIFY primaryConnectedChanged)
    Q_PROPERTY(bool secondaryConnected READ secondaryConnected  NOTIFY secondaryConnectedChanged)


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
    void setPrimaryConnected(bool connected){ _primaryConnected = connected; }
    void setSecondaryConnected(bool connected){ _secondaryConnected = connected; }

    Device* getDevbyID(int ID);
    Peripheral getPeriperalbyID(int ID);
    void connect(bool isPrimary);
    void disconnect(bool isPrimary);

    QList<Peripheral> peripherals;
    QList<Device> devices;
signals:
    void nameChanged(int ID, QString name);
    void PIPChanged(QString IP); // for qml
    void SIPChanged(QString IP); //for qml
    void IDChanged(int ID);
    void IPChanged(int ID, bool isPrimary);
    void connectStatusChanged(int ID, bool isPrimary, bool connected);
    void primaryConnectedChanged(bool isConnected);
    void secondaryConnectedChanged(bool isConnected);
    void connectionChanged(int ID);
private:
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


    HeartBeat* _primaryHeartBeat;
    HeartBeat* _secondaryHeartBeat;

};

#endif // BOATITEM_H
