import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtMultimedia 5.7


Item {
    id: root
    width: 300
    height: 400
    /*
    Audio {
              id: playSound
              source: "sound/click79.wav"
              muted: true
              onStopped: {
                  muted = false
              }
          }
*/
    SwipeView{
        id: swipeView
        anchors.fill: parent
        currentIndex: 0
        interactive: false
        clip: true
        Rectangle{
            width: 200
            height: 350
            color: "#1a1a1c"
            border.color: "#565656"
            Column{
                anchors.top: parent.top
                anchors.topMargin: 20
                spacing: 15
                anchors.horizontalCenter: parent.horizontalCenter
                Row{
                    spacing: 20
                    MenuButton{
                        imgsrc: "images/winch.png"
                        text: "Winch"
                        onClicked: {

                            swipeView.currentIndex = 1
                            loader.source = "WinchControl.qml"
                        }
                    }
                    MenuButton{
                        imgsrc: "images/videocam.png"
                        text: "Video"
                        onClicked: {
                            playSound.play()
                            loader.source = "VideoControl.qml"
                        }
                    }
                }
                Row{
                    spacing: 20
                    MenuButton{
                        imgsrc: "images/pump.png"
                        text: "Pump"
                        onClicked: {
                            playSound.play()
                            loader.source = "PumpControl.qml"
                        }

                    }
                    MenuButton{
                        imgsrc: "images/checklist.png"
                        text: "Check"
                        onClicked: {
                            playSound.play()
                            loader.source = "CheckList.qml"
                        }

                    }
                }
                Row{
                    spacing: 20
                    MenuButton{
                        imgsrc: "images/tune.png"
                        text: "Device"
                        onClicked: {
                            //playSound.play()
                            loader.source = "DeviceControl.qml"
                        }

                    }

                }

            }

        }


    }
    Loader{
        id: loader
        anchors.fill: parent
    }

    Component.onCompleted: {

        playSound.play()


    }


}

