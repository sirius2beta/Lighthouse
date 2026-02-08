#include "networkmanager.h"
#include "dncore.h"
#include <QQmlEngine>
#include "configmanager.h"
#include <QNetworkDatagram>




NetworkManager::NetworkManager(QObject *parent, DNCore *core)
    : QObject{parent}
{
    _core = core;
    serverSocket = new QUdpSocket(this);
    clientSocket = new QUdpSocket(this);
    clientSocket->bind(50008,QUdpSocket::ShareAddress);

}

void NetworkManager::init()
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    connect(clientSocket,&QUdpSocket::readyRead,this, &NetworkManager::onUDPMsg);
}

void NetworkManager::sendMsg(QHostAddress addr, uint8_t topic, QByteArray command)
{
    QByteArray cmd;
    cmd.resize(1);
    cmd[0] = topic;
    cmd.append(command);
    clientSocket->writeDatagram(cmd,cmd.size(), addr, 50006);
}

void NetworkManager::sendMsgbyID(uint8_t boatID, uint8_t topic, QByteArray command)
{
    BoatItem* boat = _core->boatManager()->getBoatbyID(boatID);
    if(boat != 0){
        command.prepend(boatID);
        sendMsg(QHostAddress(boat->currentIP()), topic, command);
    }else{
        qDebug()<<"\u001b[38;5;203m"<<"**Fatal error: NetworkManager::sendMsgbyID boatID outof range"<<"\033[0m";
    }
}

void NetworkManager::parseMsg(QHostAddress addr, const uint8_t& boatID, const mavlink_message_t &message)
{
    mavlink_custom_legacy_wrapper_t wrapper;
    mavlink_msg_custom_legacy_wrapper_decode(&message, &wrapper);
    uint8_t topic = wrapper.topic;

    QString ip = QHostAddress(addr.toIPv4Address()).toString();


    QString msgType = _core->configManager()->messageChar(topic);
    QByteArray data(reinterpret_cast<const char*>(wrapper.payload), wrapper.length);
    qDebug() << topic<<","<<msgType<<", length:"<<wrapper.length;
    return;
    if(msgType == ConfigManager::msg_heartbeat()){
        uint8_t topic = wrapper.topic;
        qDebug() << "get heartbeat";
        BoatItem* boat = _core->boatManager()->getBoatbyID(topic);

        if( boat != 0){

            emit AliveResponse(ip, boatID);
        }


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

void NetworkManager::onUDPMsg()
{

    while (clientSocket->hasPendingDatagrams()) {

        QNetworkDatagram datagram = clientSocket->receiveDatagram();

        // 自動鎖定 QGC 位址 (如前所述)
        QByteArray data = datagram.data();
        QHostAddress addr;
        QString ip;


        mavlink_message_t msg;
        mavlink_status_t status;
        uint8_t systemID;

        for (int i = 0; i < data.size(); ++i) {
            if (mavlink_parse_char(MAVLINK_COMM_0, static_cast<uint8_t>(data[i]), &msg, &status)) {
                qDebug() << "收到 MAVLink 封包! ID =" << msg.msgid
                         << "來自 SysID =" << msg.sysid
                         << "CompID =" << msg.compid;
                systemID = msg.sysid;
                switch (msg.msgid) {
                case MAVLINK_MSG_ID_PARAM_REQUEST_LIST:
                    qDebug() << "QGC 請求參數列表，正在回覆結束標記...";
                    //sendAllParameters();
                    break;

                case MAVLINK_MSG_ID_COMMAND_LONG: {
                    mavlink_command_long_t cmd;
                    mavlink_msg_command_long_decode(&msg, &cmd);

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
                    mavlink_msg_request_data_stream_decode(&msg, &req);

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
                    mavlink_msg_custom_legacy_wrapper_decode(&msg, &wrapper);
                    parseMsg(addr, systemID, msg);
                    break;
                }

                }
            }
        }
    }

}
