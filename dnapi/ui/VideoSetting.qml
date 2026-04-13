import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0

Item {
    property VideoItem _videoItem
    property VideoItem _videoItem0: DeNovoViewer.videoManager.getVideoItem(0)
    property VideoItem _videoItem1: DeNovoViewer.videoManager.getVideoItem(1)
    property int _index: 0
    property bool fullSelected: true
    Component{
        id: editBoatDialog
        EditBoatDialog{

        }
    }
    id: _root
    height:300
    width:300
    Layout.preferredWidth: 300
    Layout.fillHeight: true
    Layout.alignment: Qt.AlignLeft
    property int boatNo: 0


    function setVideoItemNo(index){ //set video item index

        _index = index
        _videoItem = DeNovoViewer.videoManager.getVideoItem(index)

        if(_videoItem){
            _videoItem.update()
        }

    }

    function setBoatID(id){
        boatNo=id
        if(_videoItem0){
            _videoItem0.setBoatID(id)
        }
        if(_videoItem1){
            _videoItem1.setBoatID(id)
        }
    }

    Rectangle{
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        color: "#222222"
        opacity: 100
        border.width: 0
        border.color: "#dddddd"

        Rectangle{
            id: _title
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 2
            height:35
            color: "#191919"

            Text{
                anchors.fill: parent
                verticalAlignment: Qt.AlignVCenter
                leftPadding: 2
                font.family: "Roboto"
                font.pixelSize: 16
                text:" Video Settings"
                color:"white"
            }
            Button {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                id: close_button
                text: ""
                topInset: 0
                bottomInset: 0
                height:30
                width:30
                property bool activate: false
                background: Rectangle {
                    color: parent.down ? "#99333333" : "#00000000"
                    //border.color: "#26282a"
                    //border.width: 1
                    implicitWidth: 45
                    implicitHeight: 45
                    radius: 4
                    Rectangle{
                        anchors.fill: parent
                        radius:4
                        anchors.margins: 5
                        color:"#00999900"
                    }

                    Image{
                        id: img3
                        anchors.margins: 5
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.left: parent.left
                        fillMode: Image.PreserveAspectFit

                        source: "qrc:/res/close.png"
                    }
                }
                onClicked: {
                    _root.parent.source = ""
                }
            }
        }
        ColumnLayout{
            anchors.top: _title.bottom
            anchors.left: parent.left
            anchors.right:  parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10
            Text {
                verticalAlignment: Text.AlignVCenter
                height:40
                width: 80
                leftPadding: 10
                text: "選擇要設置的視窗"
                font.pointSize: 10
                color: "white"
                font.family: "Microsoft Jhenghei"
            }
            Rectangle{
                id: block_display
                Layout.alignment: Qt.AlignHCenter
                width: parent.width
                implicitHeight: 150
                color: "#191919"
                states: [
                    State {
                        name: "block0selected"
                    },
                    State {
                        name: "block1selected"
                    },
                    State {
                        name: "block2selected"
                    }
                ]
                Rectangle{

                    anchors.centerIn: parent
                    width: 192
                    height: 108
                    color: block_display.state=="block0selected"?"#009ddc":"#191919"
                    border.color: "#999999"

                    Text{
                        id: block0
                        anchors.fill: parent
                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignHCenter
                        leftPadding: 2
                        font.family: "Roboto"
                        font.pixelSize: 24
                        text:""
                        color:"white"
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            fullSelected=true
                            if(block0.text!=""){
                                block_display.state = "block0selected"
                                setVideoItemNo(parseInt(block0.text))
                            }
                        }
                    }

                    Rectangle{
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.margins: 5
                        width: 64
                        height: 36
                        color: block_display.state=="block1selected"?"#009ddc":"#191919"
                        border.color: "#999999"
                        Text{
                            id: block1
                            anchors.fill: parent
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            font.family: "Roboto"
                            font.pixelSize: 20
                            text:""
                            color:"white"
                        }
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                fullSelected=false
                                if(block1.text!=""){
                                    block_display.state = "block1selected"
                                    setVideoItemNo(parseInt(block1.text))
                                }
                            }
                        }
                    }


                    Rectangle{
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 5
                        width: 64
                        height: 36
                        color: block_display.state=="block2selected"?"#009ddc":"#191919"
                        border.color: "#999999"
                        Text{
                            id: block2
                            anchors.fill: parent
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            font.family: "Roboto"
                            font.pixelSize: 20
                            text:""
                            color:"white"
                        }
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                fullSelected=false
                                if(block2.text!=""){
                                    block_display.state = "block2selected"
                                    setVideoItemNo(parseInt(block2.text))
                                }
                            }
                        }
                    }
                }

                Component.onCompleted: {

                    if(_videoItem0.blockID == 0){
                        block0.text = "0"
                    }
                    if(_videoItem1.blockID == 0){
                        block0.text = "1"
                    }
                    if(_videoItem0.blockID == 1){
                        block1.text = "0"
                    }
                    if(_videoItem1.blockID == 1){
                        block1.text = "1"
                    }
                    if(_videoItem0.blockID == 2){
                        block2.text = "0"
                    }
                    if(_videoItem1.blockID == 2){
                        block2.text = "1"
                    }
                }

            }
            RowLayout{
                Layout.fillWidth: true


                Text{
                    text: "相機狀態: "
                    color:"#ffffff"
                    font.pixelSize: 14
                }


                Rectangle{
                    id:_status_indicator
                    height:10
                    width:10
                    color: "#888888"
                }
                Text{
                    id:_status_text
                    text:"Idle"
                    color:"#ffffff"
                    font.pixelSize: 14
                }
                Rectangle{
                    id:_recording_indicator
                    height:10
                    width:10
                    radius: 5
                    color: "#999999"
                }
                Text{
                    id:_recording_text
                    Layout.fillWidth: true
                    text:"recording"
                    color:"#ffffff"
                    font.pixelSize: 14
                }
                Rectangle{
                    Layout.fillWidth: true
                }


            }



            Row{
                Text {
                    verticalAlignment: Text.AlignVCenter
                    height:40
                    width: 80
                    leftPadding: 10
                    text: "VidoeNo"
                    font.pointSize: 10
                    color: "white"
                    font.family: "Segoe UI"
                }
                ComboBox{
                    id: _videoNo
                    height:40
                    font.family: "Segoe UI"
                    model: _videoItem?_videoItem.videoNoListModel:0
                    Connections{
                        function onActivated(index) {
                            _videoItem.getVideoStatus(index)
                            console.log("set videoIndex: ", _videoItem.videoIndex)
                        }
                    }

                }
            }

            Row{

                Text {
                    verticalAlignment: Text.AlignVCenter
                    height:40
                    width: 80
                    leftPadding: 10
                    text: "Quality"
                    font.pointSize: 10
                    color: "white"
                    font.family: "Segoe UI"
                }
                ComboBox{
                    height:40

                    id: _qualityNo
                    font.family: "Segoe UI"
                    model: _videoItem?_videoItem.formatListStringModel:0

                    Connections{
                        function onActivated(index) {
                        }
                    }
                }
            }
            Row{
                Text {
                    verticalAlignment: Text.AlignVCenter
                    height:40
                    width: 80
                    leftPadding: 10
                    text: "AI model"
                    font.pointSize: 10
                    color: "white"
                    font.family: "Segoe UI"
                }
                ListModel {
                    id: cbModel
                    ListElement { text: "None"; isEnable: true }
                    ListElement { text: "Yolov8"; isEnable: false }
                    ListElement { text: "Seagrass"; isEnable: false }
                }
                ComboBox{
                    height:40

                    id: _AIType
                    font.family: "Segoe UI"
                    delegate: ItemDelegate {
                        width: _AIType.width
                        text: model.text

                        // 核心關鍵：根據 Model 決定是否禁用
                        enabled: model.isEnable

                        // 可選：調整外觀讓使用者看出「被禁用」
                        contentItem: Text {
                            text: model.text
                            font.family: "Segoe UI"
                            font.pointSize: 12
                            color: {
                                  if (!model.isEnable) return "gray"          // 禁用時顯示灰色
                                  if (_AIType.currentIndex === index) return "pink" // 選中時顯示藍色 (原本可能是粉紅)
                                  return "white"                              // 其他正常狀態顯示黑色
                              }
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        highlighted: _AIType.highlightedIndex === index
                    }
                    textRole: "text"

                    model: cbModel


                }
            }

            RowLayout{
                Layout.fillWidth: true
                spacing:5

                Text{
                    Layout.fillWidth: true
                    text:"如果沒有出現選項，請點重新整理"
                    color:"#ffffff"
                    font.pixelSize: 14
                }


                Button{
                    icon.source: "qrc:/res/renew.png"
                    Layout.alignment: Qt.AlignRight
                    onClicked: {
                        if(_videoItem){
                            _videoItem.update()
                        }
                    }
                }


            }
            RowLayout{
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                Button{


                    id: _startRecordingButton
                    font.family: "Segoe UI"
                    text: "開始錄製"
                    onClicked: {
                        if(_videoItem){
                            _videoItem.startSeagrassCameraRecording()
                        }
                    }
                }

                Button{
                    id: _stopRecordingButton
                    //height: _videoIndex.height
                    font.family: "Segoe UI"
                    text: "停止錄製"
                    onClicked: {
                        if(_videoItem){
                            _videoItem.stopSeagrassCameraRecording()
                        }
                    }
                }

            }

            RowLayout{
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                Button{


                    id: _stopButton
                    font.family: "Segoe UI"
                    text: "Stop"
                    onClicked: {
                        if(_videoItem){
                            _videoItem.stop()
                        }
                    }
                }

                Button{
                    id: _playButton
                    //height: _videoIndex.height
                    font.family: "Segoe UI"
                    text: "Play"
                    onClicked: {
                        if(_videoItem){
                            _videoItem.play(_videoNo.currentIndex, _qualityNo.currentIndex, _AIType.currentIndex)
                        }
                    }
                }

            }



            Item{
                Layout.fillHeight: true
            }
        }
    }
    Connections{
        target:_videoItem
        function onVideoNoListModelChanged(list){
            _videoNo.currentIndex = _videoItem.videoIndex
            _qualityNo.currentIndex = _videoItem.qualityIndex
            _AIType.currentIndex =_videoItem.AIType
        }
    }
    Connections{
        target:_videoItem
        function onVideoIndexChanged(index){
            _videoNo.currentIndex = index
            _videoItem.getVideoStatus(index)
        }
    }

    Connections{
        target:_videoItem
        function onQualityIndexChanged(index){
            _qualityNo.currentIndex = index
        }
    }
    Connections{
        target:_videoItem
        function onAiTypeChanged(type){
            _AIType.currentIndex = type
        }
    }
    Connections{
        target:_videoItem
        function onModelReady(index, ready){
            cbModel.setProperty(index, "isEnable", ready > 0);
        }
    }
    Connections{
        target:_videoItem
        function onStatusChanged(status){
            if(status == 0){
                _playButton.enabled = 1
                _stopButton.enabled = 0
                _status_indicator.color = "#bbbbbb"
                _status_text.text = "Stopped"
            }else if(status == 1){
                _playButton.enabled = 0
                _stopButton.enabled = 1
                _status_indicator.color = "#00ff00"
                _status_text.text = "Playing"
            }else if(status == 2){
                _playButton.enabled = 0
                _stopButton.enabled = 1
                _status_indicator.color = "#ffaa00"
                _status_text.text = "Retrying"
            }else{
                _playButton.enabled = 0
                _stopButton.enabled = 1
                _status_indicator.color = "#ff0000"
                _status_text.text = "Error"
            }
        }
    }
    Connections{
        target:_videoItem
        function onRecordingChanged(recording){
            if(recording == 0){
                _recording_indicator.color = "#999999"
            }else{
                _recording_indicator.color = "#ff0000"
            }
        }
    }

    Component.onCompleted: {
    }
}


