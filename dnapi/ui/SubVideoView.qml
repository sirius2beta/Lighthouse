import QtQuick 2.15
import QtQuick.Layouts 1.15


Item {
    id: _root
    width:      _pipSize
    property real   _pipSize:           parent.width * 0.3
    property real   _maxSize:           0.75                // Percentage of parent control size
    property real   _minSize:           0.10
    Rectangle{
        id: _background
        property real  _pipSize: parent.width * 0.2
        radius: 10
        color: "#333333"
        anchors.fill: parent
    }


    Rectangle{
        id: _resizeHandle
        anchors.horizontalCenter: parent.left
        anchors.verticalCenter: parent.verticalCenter
        height:60
        width:15
        color:"#444444"
        visible: _resize.containsMouse


    }
    MouseArea {
        id: _resize
        anchors.horizontalCenter: parent.left
        anchors.verticalCenter: parent.verticalCenter
        height:60
        width:15
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        drag{ target: _resizeHandle; axis: Drag.XAxis }
        onMouseXChanged: {
            if(drag.active){
                _root.width = _root.width - mouseX
                _root.x = _root.x + mouseX
                if(_root.width < 30)
                    _root.width = 30
            }
        }
    }
    RowLayout{
        anchors.fill: parent
        anchors.margins:10
        spacing: 10
        implicitWidth: 500
        WinchControl{

        }

    }



}
