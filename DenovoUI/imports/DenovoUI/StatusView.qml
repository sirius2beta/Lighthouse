import QtQuick 2.15
import QtQuick.Controls 2.15


Item {
    id: root
    width: 200
    implicitHeight: 720
    Rectangle{
        anchors.fill: parent
        color: "#1a1a1c"
        border.color: "#565656"

    }
    SwipeView {
        id: swipeView
        height: 300

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        clip: true
        BoatStatusPanel{
            id: boatStatusPanel
            onNextPage: {
                swipeView.currentIndex++
            }


        }
        MultiBoatPanel{

        }
    }

    BoatGaugePanel{
        anchors.top: swipeView.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: 0
        anchors.bottomMargin: 0


    }
}
