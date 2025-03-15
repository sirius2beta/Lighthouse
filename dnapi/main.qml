import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtPositioning 5.15
import QtLocation 5.15

import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0
import DeNovoViewer.Display 1.0


import DenovoUI 1.0


Window {
    FontLoader { source: "font/Roboto-Black.ttf" }
    FontLoader { source: "font/Roboto-Regular.ttf" }
    id: dnMainWindow
    width: 1280
    height: 720
    visible: true
    title: DeNovoViewer.programName
    //visibility: Window.FullScreen
    //Material.theme: Material.Dark
    //Material.accent: Material.Purple
    property DNValue dnvalue: DNValue{}

    property real lon: parseFloat(DeNovoViewer.sensorManager.mav1Model.get(1).displayValue)/10000000
    property real lat: parseFloat(DeNovoViewer.sensorManager.mav1Model.get(2).displayValue)/10000000

    property string version: "V3.1"

    Rectangle{
        color: "#111111"
        anchors.fill:parent
    }


    DNFlyView{
        id: _centerVideoView
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: _controlView.left
        //anchors.margins: 15



    }
    /*
    Rectangle{
        id: _leftTool
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "#222222"
        width:70
        ColumnLayout{
            anchors.fill:parent
            anchors.margins: 5

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                contentItem: Image{
                    fillMode: Image.PreserveAspectFit
                    id: _boatManagerIcon
                    source: "res/boatManager.png"
                }
                onClicked: popup.open()


            }
            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                radius:5
                color: "#074799"
                Text{
                    anchors.fill: parent
                    text: version
                    font.family: "Segoe UI"
                    font.pixelSize: 20
                    color:"white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                }
            }

            Image {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                fillMode: Image.PreserveAspectFit
                id: _sensorManagerIcon
                source: "res/sensorManager.png"
            }
            Item {
                Layout.fillHeight: true
            }
        }
        Popup {
                id: popup
                x: 50
                y: 10
                width: 200
                height: 50
                modal: true
                focus: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                padding: 10
                contentItem: Text {
                    text: "Version 3.0.0"
                    font.family: "Segoe UI"
                    font.pixelSize: 20
                    color:"white"
                }
        }
    }
    */

    ControlView{
        id: _controlView
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 300
        totalBatteryPercentage: parseInt(DeNovoViewer.sensorManager.mav0Model.get(3).displayValue)
        totalBatteryVoltage: parseInt(DeNovoViewer.sensorManager.mav0Model.get(1).displayValue)
        totalBatteryCurrent: parseInt(DeNovoViewer.sensorManager.mav0Model.get(2).displayValue)
    }
/*
    Rectangle{
        id: _bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 15
        radius: 10
        height:50
        color: "#25252a"
        clip: true;
        ScrollView{
            anchors.fill: parent
            RowLayout{
                anchors.fill: parent
                anchors.margins:10
                spacing: 10
                implicitWidth: 500

                BoatManagerUI{
                    id: _boatManager
                }
                Item{
                    Layout.preferredWidth: _thumbnail.width
                    Layout.fillHeight: true

                    Image {
                        height: parent.height
                        fillMode: Image.PreserveAspectFit
                        id: _thumbnail
                        source: "res/ecov4.png"
                    }

                    Rectangle{
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 5
                        radius: 2
                        color: "#438e96"
                        height:20
                        width: 80
                        Text{
                            font.family: "Segoe UI"
                            text: " Echo"
                            font.pixelSize:16
                            color: "white"
                        }
                    }
                }
                // map not used for now
                PositionSource {
                    id: src
                    updateInterval: 1000
                    active: true
                    onPositionChanged: {
                            h_point.coordinate = src.position.coordinate;
                            console.log("Coordinate:", coord.longitude, coord.latitude);
                        }

                }
                Item{
                    Layout.preferredWidth: 400
                    Layout.fillHeight: true

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
                                source: "res/home_pin.png"
                                fillMode: Image.Stretch
                            }
                        }
                        MapQuickItem{
                            id: b_point
                            zoomLevel: parent.zoomLevel
                            coordinate: QtPositioning.coordinate(lat,lon)
                            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
                            sourceItem: Image{
                                width:50
                                height:50
                                source: "res/navigation.png"
                                fillMode: Image.Stretch
                                transform: Rotation{origin.x:25; origin.y:25; angle:parseInt(DeNovoViewer.sensorManager.mav1Model.get(4).displayValue)/100}
                            }
                            onCoordinateChanged: {
                                    mmap.center = coordinate


                            }

                        }
                    }

                }


                BoatStatusView{

                }


                AquaUI{

                }



                Item {
                        Layout.fillWidth: true
                }
            }

        }






    }

*/
    QuickTab{
        id: quicktab
        anchors.bottom:parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Item {
        id: overlay
        anchors.fill: parent

    }


    Component.onCompleted: {
        DeNovoViewer.controlManager.controls.get(0).setField(0,1000)
        dnvalue = DeNovoViewer.controlManager.controls.get(0).getField(0);
        console.log(DeNovoViewer.controlManager.controls.get(0).maxSpeed)

        //console.log(parseInt(DeNovoViewer.sensorManager.mav1Model.get(0).displayValue))

    }
}
