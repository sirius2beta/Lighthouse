import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 200
    height: 350
    signal homePage()
    Rectangle{
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        color: "#1a1a1c"
        border.color: "#565656"

        Column{
            id: column
            Text {
                id: text1
                x: 8
                y: 8
                color: "#ffffff"
                text: qsTr("Winch Control")
                font.pixelSize: 12
                font.family: Constants.font.family
            }
            Rectangle{
                id: rectangle2
                height:300
                color: "#00ffffff"
                width:200
                Row{
                    id: row2
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5
                    Rectangle{
                        width:80
                        color: "#00a4a4a4"
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 20
                        anchors.bottomMargin: 20
                        Row{
                            id: row1
                            anchors.fill: parent
                            Rectangle{
                                id: rectangle1
                                width:30
                                height:parent.height
                                color: "#00ffffff"
                                anchors.top: parent.top
                                anchors.topMargin: 5
                                Column{
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    anchors.leftMargin: 5
                                    Repeater{
                                        model: 4
                                        Rectangle{
                                            height:80
                                            color: "#00ffffff"
                                            width:10
                                            Rectangle{
                                                width:50
                                                height:1
                                            }

                                            Text {
                                                color: "#ffffff"
                                                text: (index)*5
                                                horizontalAlignment: Text.AlignRight
                                                font.pointSize: 14
                                                font.family: Constants.font.family
                                            }
                                        }


                                    }

                                }
                            }
                            Rectangle{
                                width: 50
                                height:parent.height
                                color: "#00ffffff"
                                Rectangle{
                                    width: 10
                                    height:parent.height
                                    color: "green"
                                }
                                Image {
                                    id: indicator3
                                    x: 10
                                    width: 19
                                    height: 10
                                    source: "images/indicator3.png"
                                    fillMode: Image.PreserveAspectFit
                                }
                            }

                        }
                    }
                    Rectangle{
                        id: rectangle
                        width:120
                        height:300
                        color: "#00a4a4a4"
                        Column{
                            id: column1
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 5
                            DNButton{
                                width: 80
                                height: 60
                                showIcon: true
                                icon.source: "images/up.png"
                                text:""
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            DNButton{
                                width: 80
                                height: 60
                                showIcon: true
                                icon.source: "images/stop.png"
                                text:""
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            DNButton{
                                width: 80
                                height: 60
                                showIcon: true
                                icon.source: "images/down.png"
                                text:""
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text{
                                color: "#ffffff"
                                text: "speed"
                            }

                            Rectangle{
                                width:90
                                height:60
                                anchors.horizontalCenter: parent.horizontalCenter
                                Row{
                                    id: row
                                    DNButton{
                                        width: 30
                                        height: 60
                                        text:"-"
                                    }
                                    Text {
                                        width:30
                                        height:60
                                        text: "1"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    DNButton{
                                        width: 30
                                        height: 60
                                        text:"+"
                                    }
                                }
                            }
                        }


                    }
                }
            }

            DNButton{
                x: 111
                y: 307
                text:"home"
                onClicked: {
                    root.homePage()
                }
            }
        }



    }



}
