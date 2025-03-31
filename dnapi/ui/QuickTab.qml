import QtQuick
import QtQuick.Controls
import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0

Item {
    id: root
    width: 1280
    height: 110
    property string quality: ""
    property string video_no: ""
    property real port:0
    property VideoItem _videoItem
    property int _index: 0

    function setIndex(index){
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

    Rectangle{
        anchors.fill: parent
        color: "#00000000"
        border.width: 0

    }


    Row{
        anchors.fill: parent
        spacing: 15
        anchors.margins: 10
        Rectangle{
            id: boatBox
            width:220
            height:90
            color: "#bb555555"
            radius:8
            border.color:"#555555"
            border.width: 1
            Row{
                anchors.fill: parent
                spacing: 10
                anchors.leftMargin: 15
                Column{

                    spacing: 5
                    Text {
                        topPadding: 10
                        color: "#ffffff"
                        text: qsTr("BOAT")
                        font.family: "roboto"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                    Rectangle{
                        width:44
                        height:44
                        color: "#000000"
                        radius:22
                        Image {
                            id: winch
                            anchors.margins: 5
                            anchors.fill:parent
                            source: "qrc:/imports/DenovoUI/images/link.png"
                            anchors.horizontalCenter: parent.horizontalCenter
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                }

                Rectangle{
                    height:parent.height
                    width:1
                    color: "#777777"
                }

                Column{
                    spacing: 5

                    Text {
                        topPadding: 5
                        color: "#ffffff"
                        text: qsTr("text")
                        font.family: "roboto"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                    Row{
                        spacing: 5
                        Rectangle{
                            height:16
                            width:16
                            color:DeNovoViewer.boatManager.boatListModel.get(0).primaryConnected?"#339977":"#00000000"
                            Text {
                                color: DeNovoViewer.boatManager.boatListModel.get(0).primaryConnected?"#00ffff":"#ffffff"
                                text: "P"
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: DeNovoViewer.boatManager.boatListModel.get(0).primaryConnected?"roboto black":"roboto"
                                font.pixelSize: 16

                                wrapMode: Text.WordWrap
                            }

                        }


                        Text {
                            color: "#ffffff"
                            text: DeNovoViewer.boatManager.boatListModel.get(0).PIP
                            font.family: "roboto"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                    Rectangle{
                            height:1
                            width: parent.width
                            color: "#777777"
                    }
                    Row{
                        spacing: 10
                        Rectangle{
                            height:16
                            width:16
                            color:DeNovoViewer.boatManager.boatListModel.get(0).secondaryConnected?"#339977":"#00000000"
                            Text {
                                color: DeNovoViewer.boatManager.boatListModel.get(0).secondaryConnected?"#00ffff":"#ffffff"
                                text: "S"
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: DeNovoViewer.boatManager.boatListModel.get(0).secondaryConnected?"roboto black":"roboto"
                                font.pixelSize: 16
                                wrapMode: Text.WordWrap
                            }
                        }


                        Text {
                            color: "#ffffff"
                            text: DeNovoViewer.boatManager.boatListModel.get(0).SIP
                            font.family: "roboto"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }

                }
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _boatManager.visible = _boatManager.visible?false:true
                    parent.border.width = parent.border.width==1?2:1
                    parent.color = parent.color=="#bb555555"?"#bb033643":"#bb555555"
                }
            }

        }

        Rectangle{
            id: videoBox
            width:220
            height:90
            color: "#bb555555"
            radius:8
            border.color:"#555555"
            border.width: 1
            Row{
                anchors.fill: parent
                spacing: 10
                anchors.margins: 10
                Column{
                    spacing: 5
                    Text {
                        color: "#ffffff"
                        text: qsTr("Video")
                        font.family: "roboto"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                    Rectangle{
                        width:44
                        height:44
                        color: "#000000"
                        radius:22
                        Image {
                            anchors.margins: 5
                            anchors.fill:parent
                            source: "qrc:/imports/DenovoUI/images/play_arrow.png"
                            anchors.horizontalCenter: parent.horizontalCenter
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                }

                Rectangle{
                    height:parent.height
                    width:1
                    color: "#777777"
                }

                Column{
                    spacing: 15
                    Text {
                        color: "#ffffff"
                        text: "Port:"+port
                        font.family: "roboto"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        color: "#00ffff"
                        text: quality
                        font.family: "roboto"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        color: "#ffffff"
                        text: "video"+video_no
                        font.family: "roboto"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }



                }
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _control.visible = !_control.visible
                    parent.border.width = parent.border.width==1?2:1
                    parent.color = parent.color=="#bb555555"?"#bb033643":"#bb555555"
                }
            }
        }

    }
    Rectangle{
        id: _control
        anchors.bottom: parent.top
        x: videoBox.x
        height:300
        width:250
        visible: false
        radius:5
        color: "#444444"
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
            color: "#222222"


            Rectangle{
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.height-5
                color: "#222222"
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

    BoatManagerUI{
        id: _boatManager
        anchors.left: parent.left
        anchors.bottom: parent.top
        visible: false
        anchors.leftMargin: 15
    }

    Component.onCompleted: {
        setIndex(_index)
    }
}
