import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtPositioning 5.15
import QtLocation 5.15

import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0


Item {
    id: _root
    property Item pipView
    property Item pipState: videoPipState
    property bool isFull: videoPipState.state === videoPipState.fullState
    property string videoObjectName //required, bind to C++ gstreamer g_object_set
    property int display_no: 0
    property int h_resolution: 480
    property int w_resolution: 640
    property real ratio: w_resolution/h_resolution
    clip: true

    PipState {
        id:         videoPipState
        pipView:    _root.pipView
        isDark:     true
    }

    Material.theme: Material.Dark
    Material.accent: Material.Purple
    property bool controlHide: true
    property int _index: 0
    property VideoItem videoItem


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
                source: "qrc:/res/home_pin.png"
                fillMode: Image.Stretch
            }
        }
        MapQuickItem{
            id: b_point
            zoomLevel: parent.zoomLevel
            coordinate: lat? QtPositioning.coordinate(lat,lon): QtPositioning.coordinate(25, 121.3)
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
            sourceItem: Image{
                width:30
                height:30
                source: "qrc:/res/navigation.png"
                fillMode: Image.Stretch
                transform: Rotation{origin.x:25; origin.y:25; angle:parseInt(DeNovoViewer.sensorManager.mav1Model.get(4).displayValue)/100}
            }
            onCoordinateChanged: {
                    mmap.center = coordinate
            }

        }
    }



}
