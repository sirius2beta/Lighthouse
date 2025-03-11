import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 400
    height: 35
    property int currentHeading: 340

    property int boxoffset: 49-currentHeading%10*5.2

    Rectangle{
        id:background
        opacity: 1
        color: "#973b3b3b"
        anchors.fill: parent
        clip: true


        Row{
            width: 520
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 13
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle{
                id:expander
                width:boxoffset
                height:15
            }

            Repeater{
                model:10
                Rectangle{
                    required property int index
                    width: 50
                    height: 15
                    color: "#00ffffff"
                    Text {

                        color: "#ffffff"
                        text: (Math.round(currentHeading/10)*10-40+index*10)%360
                        font.family: Constants.font.family
                        font.pixelSize: 12
                    }

                }

            }


        }
        Row{
            y: 25
            width: 500
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle{
                id:expander2
                width: boxoffset
                height:10
            }
            Repeater{
                model: 10

                Rectangle {
                    width: 50
                    height: 10
                    color: "#00ffffff"


                    Row{
                        id: row

                        Rectangle {

                            width: 2
                            height: 10
                            color: "#9e9e9e"
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 0
                        }
                        Rectangle {

                            width: 8
                            height: 10
                            color: "#00ffffff"
                            anchors.bottom: parent.bottom

                        }
                        Repeater{
                            model:4
                            Rectangle {
                                id: rectangle

                                width: 10
                                height: 10
                                color: "#00ffffff"
                                Rectangle {

                                    width: 2
                                    height: 5
                                    color: "#9e9e9e"
                                    anchors.bottom: parent.bottom
                                }
                            }


                        }

                    }


                }


            }

        }




    }


    Image {
        id: headingBox
        width: 53

        height: 37
        anchors.top: parent.top
        anchors.topMargin: -2
        source: "images/headingBox.png"
        anchors.horizontalCenter: parent.horizontalCenter
        scale: 0.8
        Text {
            id: text1
            color: "#f900ff"
            font.family: Constants.font.family
            text: currentHeading
            anchors.top: parent.top
            anchors.topMargin: 1
            font.pixelSize: 19
            anchors.horizontalCenter: parent.horizontalCenter
        }

    }


}
