import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls

import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0



Item {
    width:60
    height:60*3+20*(3-1)
    property VideoItem _videoItem
    property int _index: 0
    signal openControlView()

    function setIndex(index){ //set video item index
        _index = index
        _videoItem = DeNovoViewer.videoManager.getVideoItem(index)
        _videoItem.setBoatID(DeNovoViewer.boatManager.getIDbyInex(_boatNo.currentIndex))
        console.log("init listview index:",_boatNo.currentIndex)
    }

    function setVideoItem(videoItem){
        _videoItem = videoItem
        _boatNo.currentIndex = videoItem.boatID
        _videoNo.currentIndex = videoItem.videoNo
        _qualityNo.currentIndex = videoItem.formatNo

    }

    signal openBoatSetting()
    signal openVideoSetting()

    Rectangle{
        id: right_tool
        anchors.fill: parent
        color:"#191919"
        radius:5
        ColumnLayout{
            anchors.fill:parent
            spacing: 2
            Button {
                Layout.alignment: Qt.AlignHCenter
                id: menu_button
                text: ""
                property bool activate: false
                background: Rectangle {
                    implicitWidth: 45
                    implicitHeight: 60
                    color: parent.down ? "#99333333" : "#00000000"
                    radius: 4
                    Rectangle{
                        anchors.fill: parent
                        radius:4
                        anchors.margins: 5
                        color:"#00999900"
                    }

                    Image{
                        id: img
                        anchors.margins: 5
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.left: parent.left
                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/res/menu.png"
                    }
                    Text{
                        text: "Menu"
                        color: "#ffffff"
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                onClicked: {
                    openControlView()
                }
            }
            Button {
                Layout.alignment: Qt.AlignHCenter
                id: mute_button2
                text: ""
                property bool activate: false
                background: Rectangle {
                    color: parent.down ? "#99333333" : "#00000000"
                    //border.color: "#26282a"
                    //border.width: 1
                    implicitWidth: 45
                    implicitHeight: 60
                    radius: 4
                    Rectangle{
                        anchors.fill: parent
                        radius:4
                        anchors.margins: 5
                        color:"#00999900"
                    }

                    Image{
                        id: img2
                        anchors.margins: 5
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.left: parent.left
                        fillMode: Image.PreserveAspectFit

                        source: "qrc:/res/video_display.png"
                    }
                    Text{
                        text: "Camera"
                        color: "#ffffff"
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                onClicked: {
                    //_control.visible = _control.visible?false:true
                    openVideoSetting()
                }
            }
            Button {
                Layout.alignment: Qt.AlignHCenter
                id: mute_button3
                text: ""
                property bool activate: false
                background: Rectangle {
                    color: parent.down ? "#99333333" : "#00000000"
                    //border.color: "#26282a"
                    //border.width: 1
                    implicitWidth: 45
                    implicitHeight: 60
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

                        source: "qrc:/res/sail_boat.png"
                    }
                    Text{
                        text: "Boat"
                        color: "#ffffff"
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                onClicked: {
                    openBoatSetting()
                }
            }

        }


    }
    Rectangle{
        id: _control
        anchors.top: parent.top
        anchors.right: parent.left
        height:300
        width:250
        visible: false
        radius:5
        color: "#222222"
        border.width: 2
        border.color: "#dddddd"



        Rectangle{
            id: _title
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 2
            radius: 5
            height:35
            color: "#191919"


            Rectangle{
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.height-5
                color: "#191919"
            }

            Text{
                topPadding: 5
                leftPadding: 5
                font.family: "roboto"
                font.pixelSize: 16
                text:" Video settings"
                color:"white"
            }

        }
        Column{
            anchors.horizontalCenter:  parent.horizontalCenter
            anchors.top:  _title.bottom
            anchors.topMargin: 10
            spacing:5
            Row{
                Text {
                    verticalAlignment: Text.AlignVCenter
                    height:40
                    width: 80
                    leftPadding: 10
                    text: "Boat"
                    font.pointSize: 10
                    color: "white"
                    font.family: "Segoe UI"
                }
                ComboBox {
                    id: _boatNo
                    height:40
                    editable: false
                    model: DeNovoViewer.boatManager.boatListModel
                    displayText: (currentIndex!=-1)?DeNovoViewer.boatManager.boatListModel.get(currentIndex).name:""
                    font.family: "Segoe UI"
                    Connections {
                        function onActivated(index) {
                            _videoItem.setBoatID(DeNovoViewer.boatManager.getIDbyInex(index))
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
                        highlighted: ListView.isCurrentItem
                        //required property string modelData
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
            Row{
                spacing:5
                Button{
                    icon.source: "qrc:/res/renew.png"
                    onClicked: {
                        if(_videoItem){
                            _videoItem.update()
                        }
                    }
                }

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

        }

    }




    Component.onCompleted: {
        setIndex(_index)
    }

}
