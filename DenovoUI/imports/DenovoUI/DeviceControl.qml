import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import DeNovoViewer 1.0

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

        ColumnLayout{
            anchors.fill: parent
            Text {
                id: text1
                x: 8
                y: 8
                color: "#ffffff"
                text: qsTr("Pump Control")
                font.family: Constants.font.family
                font.pixelSize: 16
            }

            Switch {
                text: qsTr("Sonar")
                font.pixelSize: 15
                font.family: "Roboto"
                checked: DeNovoViewer.controlManager.controls.get(1).power
                onClicked:{
                    DeNovoViewer.controlManager.controls.get(1).setPower(this.checked)
                }

            }
            Switch {
                text: qsTr("Cooling")
                font.pixelSize: 15
                font.family: "Roboto"
            }
            Switch {
                text: qsTr("Switch")
                font.pixelSize: 15
                font.family: "Roboto"
            }
            Switch {
                text: qsTr("Switch")
                font.pixelSize: 15
                font.family: "Roboto"
            }
            Rectangle{
                Layout.fillHeight: true
            }



            DNButton{
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins: 5
                width: 90
                height: 49
                text:"home"
                onClicked: {
                    root.parent.source = ""
                }
            }
        }



    }

}
