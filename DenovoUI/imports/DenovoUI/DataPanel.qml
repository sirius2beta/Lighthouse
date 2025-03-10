import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15


Item {
    id: root
    width: 200
    height: 364

    property int tabIndex: 0
    Rectangle{
        id:background
        color: "#1a1a1c"
        anchors.fill: parent
        border.color: "#565656"
    }
    Row{
        id: tab
        Rectangle{
            width: 50
            height: 30
            color: tabIndex == 0?"#209fbc":"#666666"
            border.color: "#ffffff"
            Text{
                color: "#ffffff"
                text:"Aqua"
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: Constants.font.family
                font.pixelSize: 16
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    tabIndex = 0;
                }
            }

        }
        Rectangle{
            width: 50
            height: 30
            color: tabIndex == 1?"#209fbc":"#666666"
            border.color: "#ffffff"
            Text{
                color: "#ffffff"
                text:"Cabin"
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: Constants.font.family
                font.pixelSize: 16
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    tabIndex = 1;
                }
            }

        }
    }
    Rectangle{
        color: "#00ffffff"
        border.color: "#00000000"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: tab.bottom
        anchors.bottom: parent.bottom


    }
}
