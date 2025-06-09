import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia


Item {
    id: root
    width: 300
    height: 300

    MediaPlayer {
        id: playSound
        source: "sound/click79.wav"
        audioOutput: AudioOutput {
            muted: true
        }
    }
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
                            playSound.play()
                            swipeView.currentIndex = 1
                            loader.source = "WinchControl.qml"
                        }
                    }
                    MenuButton{
                        imgsrc: "images/tune.png"
                        text: "Device"
                        onClicked: {
                            playSound.play()
                            loader.source = "DeviceControl.qml"
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


            }

        }


    }
    Loader{
        id: loader
        anchors.fill: parent
    }

    Component.onCompleted: {

        //playSound.play()
        playSound.audioOutput.muted = false


    }


}

