#ifndef BOATMANAGER_H
#define BOATMANAGER_H

#include <QObject>
#include <QDebug>
#include <QSettings>
#include <QStandardItemModel>
#include "boatitem.h"
#include <QMetaType>
#include <QObject>
#include <QQmlListProperty>
#include "dnqmlobjectlistmodel.h"

class DNCore;
class BoatManager: public QObject
{
    Q_OBJECT
public:
    BoatManager(QObject* parent = nullptr, DNCore* core = nullptr);
    ~BoatManager();
    Q_PROPERTY(DNQmlObjectListModel* boatListModel READ boatListModel NOTIFY onboatListModelChanged)
    Q_PROPERTY(BoatItem* activeBoat READ activeBoat  NOTIFY activeBoatChanged)

    QAbstractItemModel* model() const {return boatItemModel;}
    void init();
    Q_INVOKABLE void addBoat();
    Q_INVOKABLE void deleteBoat(int index);

    Q_INVOKABLE BoatItem* getBoatbyIndex(int index);
    BoatItem* getBoatbyID(int ID);
    Q_INVOKABLE int getIDbyInex(int index);
    Q_INVOKABLE int getIndexbyID(int ID);
    Q_INVOKABLE void setActiveBoatbyIndex(int index);
    DNQmlObjectListModel* boatListModel(void) { return &_boatListModel;}
    QString CurrentIP(QString boatname);
    BoatItem* activeBoat() { return _activeBoat; }

    int size();
signals:
    void boatAdded();
    void connectionChanged(int ID);
    void onboatListModelChanged(DNQmlObjectListModel* model);
    void activeBoatChanged();
    void sendMsgbyID(uint8_t boatID, char topic, QByteArray command);
    void IPChanged(uint8_t boatID);

public slots:
    void onBoatNameChange(int ID, QString newname);
    void onReboot(uint8_t boatID);
    void onRestartService(uint8_t boatID);
    void onStopService(uint8_t boatID);
    void onUpdate(uint8_t boatID);
    void saveSettings();


private:
    static QString settingsRoot() { return QStringLiteral("LinkConfigurations"); }
    QStandardItemModel* boatItemModel;
    QList<BoatItem*> _boatList;
    DNCore* _core;
    DNQmlObjectListModel _boatListModel;
    BoatItem* _activeBoat;
};

#endif // BOATMANAGER_H
