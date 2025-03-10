import QtQuick 2.15



Item {
    id: _root
    property string color: "#ffffff"
    property Item pipView
    property Item pipState: videoPipState


    PipState {
        id:         videoPipState
        pipView:    _root.pipView
        isDark:     true


    }
    Rectangle{

        anchors.fill: parent
        color: _root.color

    }


}
