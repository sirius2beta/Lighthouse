import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0

import DenovoUI 1.0

import QtQml.Models
import org.freedesktop.gstreamer.Qt6GLVideoItem

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
        color: isFull?"#000000":"#222222"
        radius: isFull?0:10
        clip: true
        border.width: isFull?0:1

        GstGLQt6VideoItem {
            id: video
            objectName: videoObjectName
            anchors.fill: parent
            anchors.margins: 1
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
    }

    VideoView{
        id: flight_indicator
        visible: isFull
        anchors.fill: parent
        rollAngle:-parseFloat(DeNovoViewer.sensorManager.mav1Model.get(6).displayValue)*57.29
        pitch:parseFloat(DeNovoViewer.sensorManager.mav1Model.get(5).displayValue)*57.29
    }


    ListModel {
        id: detect_model
    }

    Repeater {
        id: detection_box
        model: detect_model
        delegate: Rectangle {
            visible: isFull && videoItem.AIEnabled
            x: model.x
            y: model.y
            width: model.width
            height: model.height
            color: "transparent"
            property int lw: 2
            property string box_color: "#55ff88"
            Rectangle{
                x: 0
                y:-35
                width:30
                height:30
                color: box_color
                radius: 4
                border.width: 2
                border.color: "#ffffff"
                Image {
                    anchors.margins: 2
                    anchors.fill: parent
                    source: "qrc:/res/warning.png"
                }
            }

            Text{
                x: 40
                y: -30
                text: String(model.cy/100)+" m"
                color: box_color
            }


            Rectangle{
                color: box_color
                width: parent.width/3
                height:lw
            }
            Rectangle{
                color: box_color
                width: lw
                height:parent.height/3
            }
            Rectangle{
                color: box_color
                x:parent.width-width
                width: parent.width/3
                height: lw
            }
            Rectangle{
                color: box_color
                x:parent.width-width
                width: lw
                height:parent.height/3
            }
            Rectangle{
                color: box_color
                y:parent.height-height
                width: parent.width/3
                height: lw
            }
            Rectangle{
                color: box_color
                y:parent.height-height
                width: lw
                height:parent.height/3
            }
            Rectangle{
                color: box_color
                x:parent.width-width
                y:parent.height-height
                width: parent.width/3
                height:lw
            }
            Rectangle{
                color: box_color
                x:parent.width-width
                y:parent.height-height
                width: lw
                height: parent.height/3
            }
        }
    }

    Rectangle{
        id: radar
        visible: isFull
        width:150
        height: 150
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 10
        color: "#333333"
        border.color: "#555555"
        radius:width/2
        clip: true
        Image {
            anchors.fill: parent
            source: "qrc:/res/radar.png"
        }



        Repeater {
            model: detect_model
            delegate: Rectangle {
                width:4
                height:4
                x: -model.cx*5/parent.radius-width/2+parent.radius
                y: (model.cy>0 ||model.cy<5)? -model.cy*5/parent.radius+parent.radius: 0
                color:"#ff5555"
            }
        }
    }

    Rectangle{
        id: video_display_no
        width: 200
        height: 200
        color: "#55555555"
        radius: 10
        anchors.centerIn: parent
        visible: isFull
        Text{
            anchors.centerIn: parent
            text: display_no
            color: "#bbbbbb"
            font.pixelSize: 80
        }
    }

    Connections {
        target: videoItem
        function onQualityListModelChanged(no){
            if(no === 0){
                _root.w_resolution = 1920
                _root.h_resolution = 1080
            }else if(no === 1){
                _root.w_resolution = 1280
                _root.h_resolution = 720
            }else if(no === 2){
                _root.w_resolution = 640
                _root.h_resolution = 480
            }
            console.log("format no changed", _root.ratio)
        }
    }

    Connections {
        target: videoItem
        function onDetectionMatrixModelChanged(model){
            var count = model.length/7
            var videoRatio = 1
            var dx = 0
            var dy = 0

            if(background.width/background.height > _root.ratio){
                videoRatio = background.height/_root.h_resolution
                dx = (background.width-background.height*ratio)/2
            }else{
                videoRatio = background.width/_root.w_resolution
                dy = (background.height-background.width/_root.ratio)/2
            }

            detect_model.clear()
            for(var i = 0; i< count; i++){
                var box_x = model[i*7 + 1]*videoRatio + dx
                var box_y = model[i*7 + 2]*videoRatio + dy
                var box_w = model[i*7 + 3]*videoRatio
                var box_h = model[i*7 + 4]*videoRatio
                var box_cx = model[i*7 + 5]*1
                var box_cy = model[i*7 + 6]*1
                detect_model.append({x:box_x, y:box_y, width:box_w, height:box_h, cx: box_cx, cy: box_cy})
            }
        }
    }

    Rectangle{
        id: border
        anchors.fill: parent
        color: "#00000000"
        radius: isFull?0:10
        border.width: isFull?0:1
        border.color: "#555555"
    }

    onIsFullChanged: fade_in_out_animation.start()
    SequentialAnimation{
        id: fade_in_out_animation
        PropertyAnimation{ target: video_display_no; property: "opacity"; to: 1 ; duration:100}
        PropertyAnimation{ target: video_display_no; property: "opacity"; to: 1 ; duration:500}
        PropertyAnimation{ target: video_display_no; property: "opacity"; to: 0 ; duration:500}

    }

    function setIndex(index){
        _index = index
        videoItem = DeNovoViewer.videoManager.getVideoItem(index)
        videoItem.setBlockID(_index)
    }

    Component.onCompleted: {
        setIndex(_index)
    }

}
