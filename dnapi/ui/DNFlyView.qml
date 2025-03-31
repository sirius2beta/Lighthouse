import QtQuick 2.15

import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0
import DenovoUI 1.0

Item {
    id: root
    signal swapped(videoItem: VideoItem)
    HUD{
        id: hud
        visible: true
        opacity: 0.8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        depth:parseInt(DeNovoViewer.sensorManager.mav0Model.get(0).displayValue)
        volt:Math.round(parseFloat(DeNovoViewer.sensorManager.mav0Model.get(1).displayValue)*100)/100000
        amp:parseFloat(DeNovoViewer.sensorManager.mav0Model.get(2).displayValue)/100
        yaw:parseInt(DeNovoViewer.sensorManager.mav1Model.get(4).displayValue)/100
        temp: parseFloat(DeNovoViewer.sensorManager.cabinModel.get(0).displayValue)
        rtk:DeNovoViewer.sensorManager.mav1Model.get(0).displayValue
        boat_rssi:parseInt(DeNovoViewer.sensorManager.kbestModel.get(0).displayValue)
        ground_rssi:parseInt(DeNovoViewer.sensorManager.kbestModel.get(1).displayValue)
        gs: Math.round(parseFloat(DeNovoViewer.sensorManager.mav1Model.get(7).displayValue)*100)/100
        z:2

    }
    Item{
        anchors.top: hud.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        DNVideoView{
            id: videoView0
            pipView: _pipView
            _index:0
            videoObjectName: "videoContent0"
            display_no: 1
        }

        DNVideoView{
            id: videoView1
            pipView: _pipView
            _index: 1
            videoObjectName: "videoContent1"
            display_no: 2
        }




        PipView{
            id: _pipView
            sizeRatio: 9/16
            anchors.left:        parent.left
            anchors.top:         parent.top
            anchors.margins:        10
            item1:                  videoView0
            item2:                  videoView1
            name: "his"
            z:1
            show:                   true
            onSwapped: (videoItem) => root.swapped(videoItem)
        }
    }







}
