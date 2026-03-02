import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls 2.15
import DeNovoViewer.Display 1.0
import QtQuick.Layouts 1.15



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
    SplitView{
        anchors.top:  _title.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        orientation: Qt.Vertical

        ControlMenu {
                id: controlMenu
                // 設定初始高度比例
                SplitView.preferredHeight: parent.height * 0.5
                SplitView.minimumHeight: 150 // 設定最小值，避免選單被壓到看不見
            }

            DataPanel {
                // 設定為填充剩餘空間
                SplitView.fillHeight: true
                SplitView.minimumHeight: 100 // 確保水質圖表有足夠顯示空間
            }
    }



    onHideChanged: {
        hide?width=0:width=300
    }


}
