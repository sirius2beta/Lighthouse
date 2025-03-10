import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtMultimedia 5.7


Item {
    id: root
    width: 300
    height: 350
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
                            playSound.play()
                        }
                    }
                    MenuButton{
                        imgsrc: "images/videocam.png"
                        text: "Video"
                        onClicked: {

                            swipeView.currentIndex = 2
                            playSound.play()
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
                            swipeView.currentIndex = 3
                        }

                    }
                    MenuButton{
                        imgsrc: "images/checklist.png"
                        text: "Check"
                        onClicked: {
                            playSound.play()
                            swipeView.currentIndex = 4
                        }

                    }
                }

            }

        }
        WinchControl{
            onHomePage: swipeView.currentIndex = 0
        }
        VideoControl{
            onHomePage: swipeView.currentIndex = 0
        }
        PumpControl{
            onHomePage: swipeView.currentIndex = 0
        }
        CheckList{
            onHomePage: swipeView.currentIndex = 0
        }


    }

    Component.onCompleted: {

        playSound.play()


    }


}

