import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtPositioning 5.15
import QtLocation 5.15
import DeNovoViewer 1.0
//import DeNovoViewer.Boat 1.0
import DeNovoViewer.Display 1.0

Item {
    width: 300
    height: 700

    TabBar{
        id: tabBar
        anchors.top: parent.top
        width: parent.width
        TabButton {
            text: qsTr("Map")
            font.family: "roboto"
        }
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
                color: "#222222"
            }
            Plugin {
                    id: mapPlugin
                    name: "osm" // "mapboxgl", "esri", ...
                    // specify plugin parameters if necessary
                    PluginParameter {
                        name: "osm.mapping.custom.host";
                        value: "https://tile.thunderforest.com/transport-dark/{z}/{x}/{y}.png?apikey=2c796eecd7564631a9d4a487270185f3";
                    }
                }


            Map {
                id: mmap
                anchors.fill: parent
                plugin: mapPlugin
                activeMapType: supportedMapTypes[3] // Cycle map provided by Thunderforest

                center: h_point
                zoomLevel: 14
                copyrightsVisible: false
                MapQuickItem{
                    id: h_point
                    zoomLevel: parent.zoomLevel
                    coordinate: QtPositioning.coordinate(25, 121.3)
                    anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
                    sourceItem: Image{
                        width:50
                        height:50
                        source: "images/home_pin.png"
                        fillMode: Image.Stretch
                    }
                }
                MapQuickItem{
                    id: b_point
                    zoomLevel: parent.zoomLevel
                    coordinate: lat? QtPositioning.coordinate(lat,lon): QtPositioning.coordinate(25, 121.3)
                    anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
                    sourceItem: Image{
                        width:50
                        height:50
                        source: "images/navigation.png"
                        fillMode: Image.Stretch
                        transform: Rotation{origin.x:25; origin.y:25; angle:parseInt(DeNovoViewer.sensorManager.mav1Model.get(4).displayValue)/100}
                    }
                    onCoordinateChanged: {
                            mmap.center = coordinate


                    }

                }
            }
        }
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
                        anchors.rightMargin: 20
                        BoatStatusView{
                            Layout.fillWidth: true
                        }
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
            }
        }
    }
}
