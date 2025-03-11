import QtQuick 2.15
import QtQuick.Controls 2.15
import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0

Item {
    id: root
    width: 1280
    height: 90
    property string quality: ""
    property string video_no: ""
    property real port:0
    property VideoItem videoItem

    Rectangle{
        anchors.fill: parent
        color: "#00000000"
        border.width: 0

    }
    Rectangle{
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: "#333333"
        border.width: 0
        height:11

    }

    Row{
        anchors.fill: parent
        spacing: 15
        anchors.leftMargin: 10
        Rectangle{

            width:220
            height:90
            color: "#333333"
            radius:8
            border.color:"#5500ffff"
            border.width: 0
            Column{
                anchors.fill: parent
                spacing: 4
                anchors.leftMargin: 15
                anchors.topMargin: 10
                Row{
                    spacing: 20
                    Text {
                        color: "#ffffff"
                        text: qsTr("BOAT")
                        font.family: "roboto"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        color: "#ffffff"
                        text: qsTr("text")
                        font.family: "roboto"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }


                Row{
                    spacing: 15

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
                    Column{
                        spacing: 3
                        Row{
                            spacing: 10
                            Text {
                                color: DeNovoViewer.boatManager.boatListModel.get(0).primaryConnected?"#00ffff":"#ffffff"
                                text: "P"
                                font.family: DeNovoViewer.boatManager.boatListModel.get(0).primaryConnected?"roboto black":"roboto"
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
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
                        Row{
                            spacing: 10
                            Text {
                                color: DeNovoViewer.boatManager.boatListModel.get(0).secondaryConnected?"#00ffff":"#ffffff"
                                text: "S"
                                font.family: DeNovoViewer.boatManager.boatListModel.get(0).secondaryConnected?"roboto black":"roboto"
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
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
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _boatManager.visible = _boatManager.visible?false:true
                    parent.border.width = parent.border.width==0?2:0
                    parent.color = parent.color=="#333333"?"#033643":"#333333"
                }
            }

        }

        Rectangle{
            id: videoBox
            width:220
            height:90
            color: "#333333"
            radius:8
            border.color:"#5500ffff"
            border.width: 0
            Column{
                anchors.fill: parent
                spacing: 4
                anchors.leftMargin: 15
                anchors.topMargin: 10
                Row{
                    spacing: 20
                    Text {
                        color: "#ffffff"
                        text: qsTr("Video")
                        font.family: "roboto"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        color: "#ffffff"
                        text: "Port:"+port
                        font.family: "roboto"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }


                Row{
                    spacing: 15

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
                    Column{
                        spacing: 3

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
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _control.visible = !_control.visible
                    parent.border.width = parent.border.width==0?2:0
                    parent.color = parent.color=="#333333"?"#033643":"#333333"
                }
            }
        }

    }
    Rectangle{
        id: _control
        anchors.bottom: parent.top
        x: videoBox.x
        height:200
        width:200
        visible: false
        radius:5
        color: "#444444"
        border.width:1
        border.color:"#999999"
        Rectangle{
            id: _title
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.top
            radius: 5
            height:35
            color: "#222222"
            border.width:1
            border.color:"#999999"
            Text{

                font.family: "roboto"
                font.pixelSize: 18
                text:" Video"
                color:"white"
            }
        }
        Column{
            anchors.horizontalCenter:  parent.horizontalCenter
            spacing:5
            ComboBox {
                id: _boatNo
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
            ComboBox{
                id: _videoNo

                font.family: "Segoe UI"
                model: videoItem?videoItem.videoNoListModel:0
                Connections{
                    function onActivated(index) {
                        videoItem.setVideoIndex(index)
                        console.log("set videoIndex: ", index)
                    }
                }

            }
            ComboBox{
                id: _qualityNo
                font.family: "Segoe UI"
                model: videoItem?videoItem.formatListStringModel:0
                Connections{
                    function onActivated(index) {
                        videoItem.setFormatNo(index)
                        console.log("set formatNo:", index)
                    }
                }
            }
            Row{
                spacing:5
                Button{
                id: _stopButton

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
                Button{
                id: _playButton
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
}
