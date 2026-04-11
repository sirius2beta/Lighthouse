#include "networkmanager.h"
#include "dncore.h"
#include <QQmlEngine>
#include "configmanager.h"
#include "MAVLinkProtocol.h"
#include "UDPLink.h"
#include <QNetworkDatagram>


Q_LOGGING_CATEGORY(NetworkManagerLog, "Lighthouse.dnapi.networkmanager")

// primary port: 14560
// secondary port: 14561


uint8_t getTargetSystemId(const mavlink_message_t* msg) {
    // 獲取該訊息的定義（需要確認你的 MAVLink 庫有生成預定義的訊息表）
    const mavlink_msg_entry_t* entry = mavlink_get_msg_entry(msg->msgid);

    if (entry && entry->target_system_ofs != 255) {
        // 如果這個訊息有定義 target_system 的偏移量
        return _MAV_PAYLOAD(msg)[entry->target_system_ofs];
    }

    // 如果是廣播訊息 (如 Heartbeat) 或未知訊息，回傳 0
    return 0;
}

NetworkManager::NetworkManager(QObject *parent, DNCore *core)
    : QObject{parent}
{
    _core = core;

}

void NetworkManager::init()
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    LinkManager* linkManager = LinkManager::instance();
    linkManager->init();

    SharedLinkConfigurationPtr primaryLinkConfig = linkManager->mavlinkPrimaryUDPLink()->linkConfiguration();
    SharedLinkConfigurationPtr secondaryLinkConfg = linkManager->mavlinkSecondaryUDPLink()->linkConfiguration();
    SharedLinkConfigurationPtr forwardLinkConfig = linkManager->mavlinkForwardingLink()->linkConfiguration();
    for(int i = 0; i<_core->boatManager()->boatListModel()->count(); i++){
        qCDebug(NetworkManagerLog, "access boat");
        BoatItem* boat = qobject_cast<BoatItem*>(_core->boatManager()->boatListModel()->get(i));
        qCDebug(NetworkManagerLog, "access boat ok");
        if(boat){
            if(primaryLinkConfig){
                qobject_cast<UDPConfiguration*>(primaryLinkConfig.get())->addHost(boat->PIP(), LinkManager::instance()->primaryUDPPort());
                qCDebug(NetworkManagerLog, "add primary link host");
            }else{
                qCDebug(NetworkManagerLog, "failed to add primary link host, priamry link config not ready");
            }
            if(secondaryLinkConfg){
                qobject_cast<UDPConfiguration*>(secondaryLinkConfg.get())->addHost(boat->SIP(), LinkManager::instance()->secondaryUDPPort());
                qCDebug(NetworkManagerLog, "add secondary link host");
            }else{
                qCDebug(NetworkManagerLog, "failed to add primary link host, priamry link config not ready");
            }
        }
    }
    // add forward client of MP(14550) and QGC(14450)
    qobject_cast<UDPConfiguration*>(forwardLinkConfig.get())->addHost("127.0.0.1", 14450);
    qobject_cast<UDPConfiguration*>(forwardLinkConfig.get())->addHost("127.0.0.1", 14550);

    connect(MAVLinkProtocol::instance(), &MAVLinkProtocol::messageReceived, this, &NetworkManager::_mavlinkMessageReceived);
}



void NetworkManager::sendMsg(QHostAddress addr, LinkInterface* link, mavlink_message_t message)
{
    BoatItem* boat = _core->boatManager()->getBoatbyID(1);


    if (!link) {
        qCDebug(NetworkManagerLog) << "sendMsg: link gone!";
        return;
    }

    // 5. 發送

    uint8_t buffer[MAVLINK_MAX_PACKET_LEN];
    int len = mavlink_msg_to_send_buffer(buffer, &message);
    link->writeBytesThreadSafe(addr, 0, (const char*)buffer, len);
}

void NetworkManager::sendMsgbyID(uint8_t boatID, uint8_t topic, QByteArray command)
{
    BoatItem* boat = _core->boatManager()->getBoatbyID(boatID);

    qDebug()<<"boatID:"<<boat->ID()<<", addr:"<< boat->currentIP()<<", topic: "<<topic<<", "<<"cmd: "<<command;
    if(boat != 0){
        SharedLinkInterfacePtr sharedLink;
        if(command.size()>251){
            qCDebug(NetworkManagerLog) << "command too long!";
            return;
        }
        if(boat->primaryConnected()){
            sharedLink = LinkManager::instance()->mavlinkPrimaryUDPLink();
        }else{
            sharedLink = LinkManager::instance()->mavlinkSecondaryUDPLink();
        }
        if(!sharedLink){
            qCDebug(NetworkManagerLog) << "link loss";
            return;
        }

        uint8_t payload[251];
        memset(payload, 0, sizeof(payload));
        memcpy(payload, command.constData(), command.size());

        mavlink_message_t message{};
        mavlink_msg_custom_legacy_wrapper_pack_chan(
            1,                          // System ID
            2,                          // Component ID
            sharedLink->mavlinkChannel(),
            &message,
            1,                          // Target System
            1,                          // Target Component
            (uint8_t)command.size(),    // 原始資料長度
            topic,
            payload                     // 使用處理過的填充陣列，而非直接用 command.data()
            );

        sendMsg(QHostAddress(boat->currentIP()), sharedLink.get(), message);

    }else{
        qDebug()<<"\u001b[38;5;203m"<<"**Fatal error: NetworkManager::sendMsgbyID boatID outof range:"<<"\033[0m";
    }
}

void NetworkManager::onIPChanged(const int &ID, bool isPrimary)
{
    BoatItem* boat = _core->boatManager()->getBoatbyID(ID);
    qCDebug(NetworkManagerLog, "on ip changed");
    if(!boat){
        qCDebug(NetworkManagerLog, "no boat ID");
        return;
    }
    if(isPrimary){

        SharedLinkConfigurationPtr sharedLinConfig = LinkManager::instance()->mavlinkPrimaryUDPLink()->linkConfiguration();
        if(sharedLinConfig){
            UDPConfiguration* udpConfig = qobject_cast<UDPConfiguration*>(sharedLinConfig.get());
            udpConfig->removeAllHost();
            udpConfig->addHost(boat->PIP(), 14560);
        }
    }else{
        SharedLinkConfigurationPtr sharedLinConfig = LinkManager::instance()->mavlinkSecondaryUDPLink()->linkConfiguration();
        if(sharedLinConfig){
            UDPConfiguration* udpConfig = qobject_cast<UDPConfiguration*>(sharedLinConfig.get());
            udpConfig->removeAllHost();
            udpConfig->addHost(boat->SIP(), 14561);
        }
    }
}

void NetworkManager::parseMsg(const bool &isPrimary, const mavlink_message_t &message)
{
    mavlink_custom_legacy_wrapper_t wrapper;
    mavlink_msg_custom_legacy_wrapper_decode(&message, &wrapper);
    uint8_t topic = wrapper.topic;


    QString msgType = _core->configManager()->messageChar(topic);
    QByteArray data(reinterpret_cast<const char*>(wrapper.payload), wrapper.length);
    //qDebug() << "sysid"<<message.sysid<<","<<topic<<","<<msgType<<", length:"<<wrapper.length;
    quint8 boatID = message.sysid;
    BoatItem* boat = _core->boatManager()->getBoatbyID(boatID);
    if( boat != 0){
        boat->receivedMsg(isPrimary);
        SharedLinkInterfacePtr sharedLink;

        if(boat->primaryConnected()){
            sharedLink = LinkManager::instance()->mavlinkPrimaryUDPLink();
        }else{
            sharedLink = LinkManager::instance()->mavlinkSecondaryUDPLink();
        }
        if(!sharedLink){
            qCDebug(NetworkManagerLog) << "link loss";
            return;
        }

    }
    if(msgType == ConfigManager::msg_heartbeat()){
        uint8_t topic = wrapper.topic;
        //qDebug() << "get heartbeat";

    }else if(msgType == ConfigManager::msg_format()){
        uint8_t topic = wrapper.topic;
        emit setFormat(boatID, data);
    }else if(msgType == ConfigManager::msg_sensor()){
        //qDebug()<<"NetworkManager:: on sensor msg";
        uint8_t topic = wrapper.topic;
        emit sensorMsg(boatID, data);
    }else if(topic == ConfigManager::msg_control){
        uint8_t topic = wrapper.topic;
        emit controlMsg(boatID,data);
    }else if(topic == ConfigManager::msg_detect){
        uint8_t topic = wrapper.topic;
        emit detectMsg(topic,data);
    }else if(topic == ConfigManager::msg_devicestatus){
        uint8_t topic = wrapper.topic;
        emit deviceStatusMsg(topic, data);
    }

    const QString content = QLatin1String(" Received Topic: ")
                            + QChar(topic)
                            + QLatin1String(" Message: ") + QString::number(data.size());
    //qDebug() << content;

}

void NetworkManager::_mavlinkMessageReceived(LinkInterface* link, mavlink_message_t message)
{
    auto linkMgr = LinkManager::instance();
    SharedLinkInterfacePtr forwardLink = linkMgr->mavlinkForwardingLink();
    SharedLinkInterfacePtr primaryLink = linkMgr->mavlinkPrimaryUDPLink();
    SharedLinkInterfacePtr secondaryLink = linkMgr->mavlinkSecondaryUDPLink();

    // 1. 處理 GCS -> Boat (指令下行)
    if (forwardLink && link == forwardLink.get()) {
        _forwardMessageToBoat(message);
        return;
    }

    // 2. 處理 Boat -> GCS (遙測上行)


    // 3. 判斷來源並更新船隻狀態
    bool isPrimary = (link == primaryLink.get());
    bool isSecondary = (link == secondaryLink.get());

    if (isPrimary || isSecondary) {
        // 透過 sysid 讓對應的 BoatItem 知道自己在哪條 Link 收到包，藉此更新連線狀態
        if (message.msgid == MAVLINK_MSG_ID_CUSTOM_LEGACY_WRAPPER) {
            //qDebug() << "Received Wrapper from System ID:" << message.sysid;
            parseMsg(isPrimary, message);
        }else{
            if (!forwardLink) {
                qCDebug(NetworkManagerLog) << "Forward link unavailable";
            } else {
                // 注意：這裡應填入 GCS 的實際 IP，或確保 sendMsg 內部會處理 Link 的目標地址
                // 如果 forwardLink 是對應到 127.0.0.1，這裡建議明確指定
                sendMsg(QHostAddress::AnyIPv4, forwardLink.get(), message);
            }
        }
    }
}

void NetworkManager::_forwardMessageToBoat(mavlink_message_t message)
{
    QList<BoatItem*> targetBoats;
    bool isBroadcast = (message.msgid == MAVLINK_MSG_ID_HEARTBEAT ||
                            message.msgid == MAVLINK_MSG_ID_GPS_RTCM_DATA ||
                            message.msgid == MAVLINK_MSG_ID_GPS_INJECT_DATA ||
                            message.msgid == MAVLINK_MSG_ID_STATUSTEXT);

    if (isBroadcast) {
        for (int i = 0; i < _core->boatManager()->size(); ++i) {
            targetBoats.append(_core->boatManager()->getBoatbyIndex(i));
        }
    }else{
        uint8_t targetSysID = getTargetSystemId(&message);

        // 取得所有需要發送的目標船隻

        if (targetSysID == 0) {
            // 廣播：加入所有船
            for (int i = 0; i < _core->boatManager()->size(); ++i) {
                targetBoats.append(_core->boatManager()->getBoatbyIndex(i));
            }
        } else {
            // 定向：只加入特定 ID 的船
            BoatItem* boat = _core->boatManager()->getBoatbyID(targetSysID);
            if (boat) targetBoats.append(boat);
        }
    }


    // 統一發送處理
    for (BoatItem* boat : targetBoats) {
        if (!boat) continue;

        // 決定使用哪條 Link
        SharedLinkInterfacePtr sharedLink;
        if (boat->primaryConnected()) {
            sharedLink = LinkManager::instance()->mavlinkPrimaryUDPLink();
        } else if (boat->secondaryConnected()) {
            sharedLink = LinkManager::instance()->mavlinkSecondaryUDPLink();
        }else{
            continue;
        }

        if (!sharedLink) {
            qCDebug(NetworkManagerLog) << "Boat" << boat->ID() << "has no active link";
            continue;
        }

        QString ip = boat->currentIP();
        if (!ip.isEmpty()) {

            sendMsg(QHostAddress(ip), sharedLink.get(), message);
        }
    }
}
