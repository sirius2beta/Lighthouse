import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls 2.15


Item {
    id: root
    width: 300
    implicitHeight: 720
    property int totalBatteryPercentage: 10
    property int totalBatteryVoltage: 10
    property int totalBatteryCurrent: 10
    property int cabinTemp: 25
    Rectangle{
        anchors.fill: parent
        color: "#1a1a1c"
        border.color: "#565656"

    }
    ControlMenu{
        id: controlMenu

    }
    DataPanel{
        anchors.top:controlMenu.bottom
    }


}
