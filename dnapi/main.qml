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
    id: dnMainWindow
    width: 1280
    height: 720
    visible: true
    title: "LightHouse v5.3 (GPlayer v5 47aa2c4)"
    property DNValue dnvalue: DNValue{}

    property real lon: parseFloat(DeNovoViewer.sensorManager.mav1Model.get(1).displayValue)/10000000
    property real lat: parseFloat(DeNovoViewer.sensorManager.mav1Model.get(2).displayValue)/10000000

    property int currentBoatIndex: 0

    Rectangle{
        color: "#111111"
        anchors.fill:parent
    }

    HUD{
        id: hud
        visible: true
        opacity: 0.8
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
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
        primaryConnected: DeNovoViewer.boatManager.boatListModel.get(currentBoatIndex).primaryConnected
        secondaryConnected: DeNovoViewer.boatManager.boatListModel.get(currentBoatIndex).secondaryConnected
    }

    DNFlyView{
        id: _centerVideoView
        anchors.bottom: status_bar.top
        anchors.top: hud.bottom
        anchors.left: parent.left
        width: parent.width - right_drawer.position
        onSwapped:function(videoItem){

        }

    }

    RightTool{
        id: right_tool
        anchors.right: parent.right
        anchors.top: hud.bottom
        anchors.margins: 5


        onOpenControlView:{
            //_controlView.hide = _controlView.hide?false:true
            right_block.source = "qrc:/imports/DenovoUI/ControlView.qml"

            right_block.item.totalBatteryPercentage = Qt.binding(function(){ return parseInt(DeNovoViewer.sensorManager.mav0Model.get(3).displayValue)})
            right_block.item.totalBatteryVoltage=  Qt.binding(function(){ return parseInt(DeNovoViewer.sensorManager.mav0Model.get(1).displayValue)})
            right_block.item.totalBatteryCurrent=  Qt.binding(function(){ return parseInt(DeNovoViewer.sensorManager.mav0Model.get(2).displayValue)})
            right_drawer.open()
        }
        onOpenBoatSetting:{
            right_block.source = "qrc:/qml/DeNovoViewer/Display/BoatSetting.qml"
            right_drawer.open()
        }
        onOpenVideoSetting:{
            right_block.source = "qrc:/qml/DeNovoViewer/Display/VideoSetting.qml"
            right_block.item.setBoatID(0)
            right_drawer.open()
        }
    }

    Drawer{
        id: right_drawer
        width:300
        y:72
        height: parent.height
        edge:           Qt.RightEdge
        dragMargin:     0
        closePolicy:    Drawer.NoAutoClose
        interactive: false
        visible: false
        dim: false

        Rectangle{
            anchors.fill: parent
            anchors.topMargin: -16
            color:"#000000"
        }


        Loader{
            id: right_block
            anchors.fill: parent
            anchors.topMargin: -16
            onSourceChanged: {
                if(!right_block.loaded()){
                    right_drawer.visible = false
                }
            }


        }

    }



    Rectangle{
        id: status_bar
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        //height:40
        color: "#222222"
        ComboBox {
            anchors.right: parent.right
            id: _boatNo
            //height:40
            editable: false
            model: DeNovoViewer.boatManager.boatListModel
            displayText: (currentIndex!=-1)?DeNovoViewer.boatManager.boatListModel.get(currentIndex).name:""
            font.family: "Segoe UI"
            delegate: ItemDelegate  {
                width: _boatNo.width;
                height: 30
                Text {
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                    text: object.name
                    font.pointSize: 10
                    color: "white"
                    font.family: "Segoe UI"
                }
                highlighted: ListView.isCurrentItem
                //required property string modelData
            }
        }
    }


    Component.onCompleted: {
        DeNovoViewer.controlManager.controls.get(0).setField(0,1000)
        console.log("the value is:"+DeNovoViewer.controlManager.controls.get(0).getField(0).toInt());
        //console.log(DeNovoViewer.controlManager.controls.get(0).maxSpeed)

        //console.log(parseInt(DeNovoViewer.sensorManager.mav1Model.get(0).displayValue))

    }
}
