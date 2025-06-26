import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls 2.15


Item {
    id: _root
    width: 300
    implicitHeight: 720
    property int totalBatteryPercentage: 10
    property int totalBatteryVoltage: 10
    property int totalBatteryCurrent: 10
    property int cabinTemp: 25
    property bool hide: true
    Rectangle{
        anchors.fill: parent
        color: "#1a1a1c"

    }



    Rectangle{
        id: _title
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 2

        height:35
        color: "#191919"

        Text{
            anchors.fill: parent
            verticalAlignment: Qt.AlignVCenter
            leftPadding: 2
            font.family: "Roboto"
            font.pixelSize: 16
            text:" Menu"
            color:"white"
        }
        Button {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            id: close_button
            text: ""
            topInset: 0
            bottomInset: 0
            height:30
            width:30
            property bool activate: false
            background: Rectangle {
                color: parent.down ? "#99333333" : "#00000000"
                //border.color: "#26282a"
                //border.width: 1
                implicitWidth: 45
                implicitHeight: 45
                radius: 4
                Rectangle{
                    anchors.fill: parent
                    radius:4
                    anchors.margins: 5
                    color:"#00999900"
                }

                Image{
                    id: img3
                    anchors.margins: 5
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.left: parent.left
                    fillMode: Image.PreserveAspectFit

                    source: "qrc:/res/close.png"
                }
            }
            onClicked: {
                _root.parent.source = ""

            }
        }
    }


    ControlMenu{
        height: parent.height/2
        id: controlMenu
        anchors.top:  _title.bottom

    }
    DataPanel{
        anchors.top:controlMenu.bottom
    }

    onHideChanged: {
        hide?width=0:width=300
    }


}
