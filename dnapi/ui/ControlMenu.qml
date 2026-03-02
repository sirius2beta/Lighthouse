import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import DeNovoViewer.Display 1.0



Item {
    id: root
    width: 300
    height: 300

    MediaPlayer {
        id: playSound
        source: "qrc:/res/click79.wav"
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
                        imgsrc: "qrc:/res/winch.png"
                        text: "Winch"
                        onClicked: {
                            playSound.play()
                            swipeView.currentIndex = 1
                            loader.source = "WinchControl.qml"
                        }
                    }
                    MenuButton{
                        imgsrc: "qrc:/res/tune.png"
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
                        imgsrc: "qrc:/res/pump.png"
                        text: "Pump"
                        onClicked: {
                            playSound.play()
                            loader.source = "PumpControl.qml"
                        }

                    }
                    MenuButton{
                        imgsrc: "qrc:/res/checklist.png"
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

