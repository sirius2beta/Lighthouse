import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0

import DenovoUI 1.0


import org.freedesktop.gstreamer.Qt6GLVideoItem

Item {
    id: _root
    property Item pipView
    property Item pipState: videoPipState
    property bool isFull: videoPipState.state === videoPipState.fullState
    property string videoObjectName //required, bind to C++ gstreamer g_object_set




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
    function setIndex(index){
        _index = index
        videoItem = DeNovoViewer.videoManager.getVideoItem(index)
        videoItem.setBoatID(DeNovoViewer.boatManager.getIDbyInex(_boatNo.currentIndex))
        console.log("init listview index:",_boatNo.currentIndex)
    }
    property var labelMap : [
        "person",         "bicycle",    "car",           "motorbike",     "aeroplane",   "bus",           "train",
        "truck",          "boat",       "traffic light", "fire hydrant",  "stop sign",   "parking meter", "bench",
        "bird",           "cat",        "dog",           "horse",         "sheep",       "cow",           "elephant",
        "bear",           "zebra",      "giraffe",       "backpack",      "umbrella",    "handbag",       "tie",
        "suitcase",       "frisbee",    "skis",          "snowboard",     "sports ball", "kite",          "baseball bat",
        "baseball glove", "skateboard", "surfboard",     "tennis racket", "bottle",      "wine glass",    "cup",
        "fork",           "knife",      "spoon",         "bowl",          "banana",      "apple",         "sandwich",
        "orange",         "broccoli",   "carrot",        "hot dog",       "pizza",       "donut",         "cake",
        "chair",          "sofa",       "pottedplant",   "bed",           "diningtable", "toilet",        "tvmonitor",
        "laptop",         "mouse",      "remote",        "keyboard",      "cell phone",  "microwave",     "oven",
        "toaster",        "sink",       "refrigerator",  "book",          "clock",       "vase",          "scissors",
        "teddy bear",     "hair drier", "toothbrush"
    ]


    Rectangle{
        id: background
        anchors.fill: parent
        color: isFull?"#333333":"#000000"
        radius: isFull? 10: 0
        clip: true
        property real heightRatio: height/416
        GstGLQt6VideoItem {
            id: video
            objectName: videoObjectName
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
        }
        Item{
            id: _flightIndicator
            anchors.fill: parent
            visible: isFull
            Image {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                height: 80
                fillMode: Image.PreserveAspectFit
                id: _thumbnail2
                source: "qrc:/res/videoMiddleIndicater.png"
            }
        }

/*
        Repeater{
            model:10
            Rectangle{
                id:_detectbox2
                Rectangle{
                    width:4
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    color: "#ffffff"
                    border.color: "#333333"
                    border.width: 1
                }
                Rectangle{
                    width:4
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    color: "#ffffff"
                    border.color: "#333333"
                    border.width: 1
                }
                Rectangle{
                    height:4
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.right: parent.right
                    color: "#ffffff"
                    border.color: "#333333"
                    border.width: 1
                }
                Rectangle{
                    height:4
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    color: "#ffffff"
                    border.color: "#333333"
                    border.width: 1
                }

                color: "#66660000"
                visible: isFull
                x:(parent.width-parent.height*4/3)/2 + parseInt(DeNovoViewer.sensorManager.detection.get(index*6+1).displayValue)* parent.height/640*(4/3)
                y:parseInt(DeNovoViewer.sensorManager.detection.get(index*6+2).displayValue)* parent.height/480
                width: (parseInt(DeNovoViewer.sensorManager.detection.get(index*6+3).displayValue))* (parent.height*4/3)/640
                height: (parseInt(DeNovoViewer.sensorManager.detection.get(index*6+4).displayValue))* parent.height/480
                //x:(parent.width-parent.height)/2 + parseInt(DeNovoViewer.sensorManager.detection.get(index*6+1).displayValue)* parent.height/416
                //y:parseInt(DeNovoViewer.sensorManager.detection.get(index*6+2).displayValue)* parent.height/416
                //width: (parseInt(DeNovoViewer.sensorManager.detection.get(index*6+3).displayValue))* parent.height/416
                //height: (parseInt(DeNovoViewer.sensorManager.detection.get(index*6+4).displayValue))* parent.height/416

                Rectangle{
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    height:2
                    width:10
                }
                Rectangle{
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    height:10
                    width:2
                }
                Text {
                    id:label
                    anchors.top: parent.bottom
                    anchors.left: parent.left
                    height:18
                    width:80
                    color: "#ffffff"
                    font.family: "Segoe UI"
                    text: labelMap[parseInt(DeNovoViewer.sensorManager.detection.get(index*6+0).displayValue)]
                    font.pixelSize: 16
                }
                Text {
                    id:dis
                    anchors.top: label.bottom
                    anchors.left: parent.left
                    height:18
                    width:80
                    color: "#ffffff"
                    font.family: "Segoe UI"
                    text: Math.round(parseInt(DeNovoViewer.sensorManager.detection.get(index*6+5).displayValue/100))/10+" m"
                    font.pixelSize: 16
                }

            }

        }
        */


        Rectangle{
            id: _toggle
            anchors.bottom: _control.top
            anchors.horizontalCenter: parent.horizontalCenter

            height:30
            width:100
            radius:8
            color: "#333333"
            visible: isFull
            Rectangle{
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 8
                color: "#333333"
            }

            Text {
                anchors.centerIn: parent
                id: _text
                color: "#888888"
                text: "▲"
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    controlHide = controlHide?false:true
                    _control.height = controlHide?0:60
                    _text.text = controlHide?"▲":"▼"
                }
            }
        }

        Rectangle{
            id: _control
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height:0
            color: "#333333"
            visible: isFull
            clip: true
            Button{
                id: _playButton
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 5
                height: _videoNo.height
                font.family: "Segoe UI"
                text: "Play"
                onClicked: {
                    if(videoItem){
                        videoItem.play()
                        console.log("play")
                    }
                }

            }
            Button{
                id: _stopButton
                anchors.right: _playButton.left
                anchors.bottom: parent.bottom
                anchors.margins: 5
                height: _videoNo.height
                font.family: "Segoe UI"
                text: "Stop"
                onClicked: {
                    if(videoItem){
                        videoItem.stop()
                        console.log("stop")
                    }
                }

            }
            ComboBox{
                id: _qualityNo

                anchors.right: _stopButton.left
                anchors.bottom: parent.bottom
                anchors.margins: 5
                font.family: "Segoe UI"
                model: videoItem?videoItem.formatListStringModel:0
                Connections{
                    function onActivated(index) {
                        videoItem.setFormatNo(index)
                        console.log("set formatNo:", index)
                    }
                }
            }

            ComboBox{
                id: _videoNo
                anchors.right: _qualityNo.left
                anchors.bottom: parent.bottom
                anchors.margins: 5
                font.family: "Segoe UI"
                model: videoItem?videoItem.videoNoListModel:0
                Connections{
                    function onActivated(index) {
                        videoItem.setVideoIndex(index)
                        console.log("set videoIndex: ", index)
                    }
                }

            }

            ComboBox {
                id: _boatNo
                anchors.right: _videoNo.left
                anchors.bottom: parent.bottom
                anchors.margins: 5
                editable: false
                model: DeNovoViewer.boatManager.boatListModel
                displayText: (currentIndex!=-1)?DeNovoViewer.boatManager.boatListModel.get(currentIndex).name:""
                font.family: "Segoe UI"
                Connections {
                    function onActivated(index) {
                        videoItem.setBoatID(DeNovoViewer.boatManager.getIDbyInex(index))
                        console.log("listview index:",_boatNo.currentIndex)
                    }

                }
                Connections{
                    target: DeNovoViewer.boatManager
                    function onBoatAdded() {
                        if(_boatNo.currentIndex == -1){
                            _boatNo.currentIndex = 0
                        }
                    }
                }

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
                    //required property string modelData
                }

            }
        }

    }

    VideoView{
        visible: isFull
        anchors.fill: parent
        rollAngle:-parseFloat(DeNovoViewer.sensorManager.mav1Model.get(6).displayValue)*57.29
        pitch:parseFloat(DeNovoViewer.sensorManager.mav1Model.get(5).displayValue)*57.29
    }

    Component.onCompleted: {
        setIndex(_index)
    }

}
