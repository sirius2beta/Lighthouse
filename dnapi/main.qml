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
        onSwapped: (videoItem) => {
            quicktab.setVideoItem(videoItem)
        }
    }

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
        console.log("the value is:"+DeNovoViewer.controlManager.controls.get(0).getField(0).toInt());
        //console.log(DeNovoViewer.controlManager.controls.get(0).maxSpeed)

        //console.log(parseInt(DeNovoViewer.sensorManager.mav1Model.get(0).displayValue))

    }
}
