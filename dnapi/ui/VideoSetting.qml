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
        _videoItem.setBoatID(DeNovoViewer.boatManager.getIDbyInex(id))
        console.log("init listview index:",index)
    }

    function setBoatID(id){
        boatNo=id
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
                            _videoItem.setVideoIndex(index)
                            console.log("set videoIndex: ", index)
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
                            _videoItem.setFormatNo(index)
                            console.log("set formatNo:", index)
                        }
                    }
                }
            }
            Switch {
                    text: qsTr("AI detect")
                    checked: _videoItem.AIEnabled
                    onClicked: _videoItem.setAIEnabled(checked)
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
                    //height: _videoNo.height
                    font.family: "Segoe UI"
                    text: "Play"
                    onClicked: {
                        if(_videoItem){
                            _videoItem.play()
                        }
                    }
                }

            }



            Item{
                Layout.fillHeight: true
            }
        }
    }
    Component.onCompleted: {

    }
}


