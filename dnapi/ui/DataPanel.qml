import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtPositioning 5.15
import QtLocation 5.15
import DeNovoViewer 1.0
import DeNovoViewer.Display 1.0

Item {
    width: 300
    implicitHeight:400
    TabBar{
        id: tabBar
        anchors.top: parent.top
        width: parent.width

        TabButton {
            text: qsTr("Data")
            font.family: "roboto"
        }
        TabButton {
            text: qsTr("System")
            font.family: "roboto"
        }
        onCurrentIndexChanged: {
            swipeView.setCurrentIndex(currentIndex)
        }

    }
    SwipeView{
        id: swipeView
        anchors.top: tabBar.bottom
        anchors.bottom: parent.bottom
        width:parent.width
        interactive: false
        clip: true

        Item{
            Rectangle{
                anchors.fill: parent
                anchors.margins: 10
                color: "#222222"
                ScrollView{
                    anchors.fill:parent
                    contentWidth: parent.width
                    contentHeight: 1600
                    ColumnLayout{
                        anchors.fill: parent

                        AquaUI{
                            Layout.fillWidth: true
                        }


                    }
                }


            }
        }
        Item{
            Rectangle{
                anchors.fill: parent
                color: "#222222"
                ColumnLayout{
                    anchors.fill: parent
                    spacing: 0
                    AquaDataGraph{
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150 // 讓圖表自動填滿剩餘的所有高度

                        Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: "red"
                                border.width: 1
                            }
                    }
                    AquaDataGraph{
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150 // 讓圖表自動填滿剩餘的所有高度
                    }
                    AquaDataGraph{
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150 // 讓圖表自動填滿剩餘的所有高度
                    }
                    Rectangle{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#00000000"
                    }
                }


            }

        }

    }
}
