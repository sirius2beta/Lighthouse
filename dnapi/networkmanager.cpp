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


    connect(MAVLinkProtocol::instance(), &MAVLinkProtocol::messageReceived, this, &NetworkManager::_mavlinkMessageReceived);
}



void NetworkManager::sendMsg(QHostAddress addr, LinkInterface* link, mavlink_message_t message)
{
    if (!link) {
        qCDebug(NetworkManagerLog) << "sendMsg: link gone!";
        return;
    }

    // 5. 發送

    uint8_t buffer[MAVLINK_MAX_PACKET_LEN];
    int len = mavlink_msg_to_send_buffer(buffer, &message);
    link->writeBytesThreadSafe(addr, (const char*)buffer, len);
}

void NetworkManager::sendMsgbyID(uint8_t boatID, uint8_t topic, QByteArray command)
{
    BoatItem* boat = _core->boatManager()->getBoatbyID(boatID);
    if(boat != 0){
        SharedLinkInterfacePtr sharedLink;
        command.prepend(boatID);
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
        qDebug()<<"\u001b[38;5;203m"<<"**Fatal error: NetworkManager::sendMsgbyID boatID outof range"<<"\033[0m";
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
            udpConfig->addHost(boat->PIP(), 14560);
        }
    }else{

        SharedLinkConfigurationPtr sharedLinConfig = LinkManager::instance()->mavlinkSecondaryUDPLink()->linkConfiguration();
        if(sharedLinConfig){
            UDPConfiguration* udpConfig = qobject_cast<UDPConfiguration*>(sharedLinConfig.get());
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
    qDebug() << "sysid"<<message.sysid<<","<<topic<<","<<msgType<<", length:"<<wrapper.length;
    quint8 boatID = message.sysid;
    BoatItem* boat = _core->boatManager()->getBoatbyID(boatID);
    if( boat != 0){
        boat->receivedMsg(isPrimary);
        return;
    }
    if(msgType == ConfigManager::msg_heartbeat()){
        uint8_t topic = wrapper.topic;
        qDebug() << "get heartbeat";

    }else if(msgType == ConfigManager::msg_format()){
        uint8_t topic = wrapper.topic;
        emit setFormat(topic, data);
    }else if(msgType == ConfigManager::msg_sensor()){
        //qDebug()<<"NetworkManager:: on sensor msg";
        uint8_t topic = wrapper.topic;
        emit sensorMsg(topic, data);
    }else if(topic == ConfigManager::msg_control){
        uint8_t topic = wrapper.topic;
        emit controlMsg(topic,data);
    }else if(topic == ConfigManager::msg_detect){
        uint8_t topic =wrapper.topic;
        emit detectMsg(topic,data);
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
    bool isPrimary = true;
    if(link == LinkManager::instance()->mavlinkPrimaryUDPLink().get()){
        isPrimary = true;
    }else{
        isPrimary = false;
    }


    mavlink_status_t status;
    uint8_t systemID;
            systemID = message.sysid;
            switch (message.msgid) {
            case MAVLINK_MSG_ID_PARAM_REQUEST_LIST:
                qDebug() << "QGC 請求參數列表，正在回覆結束標記...";
                //sendAllParameters();
                break;

            case MAVLINK_MSG_ID_COMMAND_LONG: {
                mavlink_command_long_t cmd;
                mavlink_msg_command_long_decode(&message, &cmd);

                qDebug() << "收到 COMMAND_LONG, 指令編號:" << cmd.command;

                // 常見的初始指令：
                // 520: MAV_CMD_REQUEST_AUTOPILOT_CAPABILITIES (詢問飛控能力)
                // 511: MAV_CMD_REQUEST_MESSAGE (詢問特定訊息)

                // 無論收到什麼指令，先回覆一個「我收到了」的確認 (ACK)
                if (cmd.command == MAV_CMD_REQUEST_MESSAGE) {
                    float requestedMsgId = cmd.param1;
                    qDebug() << "QGC 請求特定訊息，ID =" << requestedMsgId;
                    if (requestedMsgId == MAVLINK_MSG_ID_AUTOPILOT_VERSION) {
                        //sendAutopilotVersion();
                    }else if (requestedMsgId == MAVLINK_MSG_ID_HOME_POSITION) {
                        //sendHomePosition();
                    }else if (requestedMsgId == 280) {
                        //sendResultAck(msg.sysid, msg.compid, cmd.command, MAV_RESULT_ACCEPTED);
                        // 這裡可以主動發送一次當前的 Radio Status
                        //sendRadioStatus();
                    }
                }
                //sendResultAck(msg.sysid, msg.compid, cmd.command);
                break;
            }
            case MAVLINK_MSG_ID_REQUEST_DATA_STREAM: { //66
                mavlink_request_data_stream_t req;
                mavlink_msg_request_data_stream_decode(&message, &req);

                qDebug() << "收到資料流請求！"
                         << "Stream ID:" << req.req_stream_id
                         << "期望頻率:" << req.req_message_rate << "Hz"
                         << "開啟狀態:" << (req.start_stop ? "Start" : "Stop");

                // 通常我們不需要給予特定的 ACK，但你可以根據這個請求來啟動或調整你的發送 Timer
                // 如果你已經在發送了，只需在日誌紀錄即可。
                break;
            }
            case MAVLINK_MSG_ID_HEARTBEAT:{
                // 收到 QGC 的心跳
                break;
            }case MAVLINK_MSG_ID_CUSTOM_LEGACY_WRAPPER:{
                qDebug() << "收到CUSTOM_LEGACY_WRAPPER！";
                mavlink_custom_legacy_wrapper_t wrapper;
                mavlink_msg_custom_legacy_wrapper_decode(&message, &wrapper);
                parseMsg(isPrimary, message);
                break;
            }

            }


}
