import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 200
    height: 350
    signal homePage()
    Rectangle{
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        color: "#1a1a1c"
        border.color: "#565656"


        Text {
            id: text1
            x: 8
            y: 8
            color: "#ffffff"
            text: qsTr("Pump Control")
            font.family: Constants.font.family
            font.pixelSize: 16
        }

        Image {
            id: image
            width: 100
            height: 100
            anchors.verticalCenter: parent.verticalCenter
            source: "images/construction.png"
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: text2
            color: "#ffffff"
            text: qsTr("Building...")
            anchors.top: image.bottom
            font.pixelSize: 18
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 0
            font.family: Constants.font
        }

        DNButton{
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 5
            width: 90
            height: 49
            text:"home"
            onClicked: {
                root.homePage()
            }
        }

    }

}
