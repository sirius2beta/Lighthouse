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
            ScrollView{
                anchors.fill:parent
                contentWidth: parent.width
                contentHeight: 1600
                Rectangle{
                    anchors.fill: parent
                    color: "#222222"
                    ColumnLayout{
                        anchors.fill: parent
                        spacing: 0
                        AquaDataGraph {
                            sensorName: "測試 (m)"
                            dataKey: "value"
                            lineColor: "#00BCFF"
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 15
                            Layout.maximumHeight: 150

                        }
                        AquaDataGraph {
                            sensorName: "水深 (m)"
                            dataKey: "depth"
                            lineColor: "#00BCFF"
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 15
                            Layout.maximumHeight: 150

                        }
                        AquaDataGraph {
                            sensorName: "溫度 (C)"
                            dataKey: "temp"
                            lineColor: "#00BCFF"
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 15
                            Layout.maximumHeight: 150

                        }

                        Item { Layout.fillHeight: true
                            Layout.minimumHeight: 10

                        }
                    }


                }
            }



        }

    }
}
