﻿import QtQuick 2.15
import QtQuick.Window 2.15
import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0

Item {
    id:         _root
    width:      _pipSize
    height:     _pipSize * sizeRatio
    visible:    item2 && item2.pipState !== item2.pipState.window && show
    property real sizeRatio: 3/4

    property string name: "mine"
    property var    item1:                  null    // Required
    property var    item2:                  null    // Optional, may come and go
    property string item1IsFullSettingsKey          // Settings key to save whether item1 was saved in full mode
    property bool   show:                   true

    readonly property string _pipExpandedSettingsKey: "IsPIPVisible"

    property var    _fullItem
    property int count: 0
    property var    _pipOrWindowItem
    property alias  _windowContentItem: window.contentItem
    property alias  _pipContentItem:    pipContent
    property bool   _isExpanded:        true
    property real   _pipSize:           parent.width * 0.2
    property real   _maxSize:           0.75                // Percentage of parent control size
    property real   _minSize:           0.10
    property bool   _componentComplete: false
    property bool   _isInitiated: false

    signal swapped(videoItem: VideoItem)

    Component.onCompleted: {
        _initForItems()
        _componentComplete = true
    }

    onItem2Changed: _initForItems()

    function showWindow() {
        window.width = _root.width
        window.height = _root.height
        window.show()
    }

    function _initForItems() {
        if(_isInitiated){
            return
        }

        var item1IsFull = true
        if (item1 && item2) {
            item1.pipState.state = item1IsFull ? item1.pipState.fullState : item1.pipState.pipState
            item2.pipState.state = item1IsFull ? item2.pipState.pipState : item2.pipState.fullState
            _fullItem = item1IsFull ? item1 : item2
            _pipOrWindowItem = item1IsFull ? item2 : item1
        } else {
            console.log(count+" hi " +name)
            count = count+1
            item1.pipState.state = item1.pipState.fullState

            _fullItem = item1
            _pipOrWindowItem = null
        }
        _setPipIsExpanded(true)
        _isInitiated = true
    }

    function _swapPip() {
        var item1IsFull = false

        if (item1.pipState.state === item1.pipState.fullState) {
            item1.pipView = this
            item1.pipState.pipView = this
            item2.pipView = this
            item2.pipState.pipView = this
            item1.pipState.state = item1.pipState.pipState
            item2.pipState.state = item2.pipState.fullState
            _fullItem = item2
            _pipOrWindowItem = item1
            item1IsFull = false
            swapped(item2.videoItem)
            console.log("item1 state => not full")
        } else {
            item1.pipView = this
            item1.pipState.pipView = this
            item2.pipView = this
            item2.pipState.pipView = this
            item1.pipState.state = item1.pipState.fullState
            item2.pipState.state = item2.pipState.pipState
            _fullItem = item1
            _pipOrWindowItem = item2
            item1IsFull = true
            swapped(item1.videoItem)
            console.log("item2 state => not full")
        }


    }

    function _setPipIsExpanded(isExpanded) {
        _isExpanded = isExpanded
    }

    Window {
        id:         window
        visible:    false

        onClosing: {
            var item = contentItem.children[0]
            if (item) {
                item.pipState.windowAboutToClose()
                item.pipState.state = item.pipState.pipState
            }
        }
    }

    Item {
        id:             pipContent
        anchors.fill:   parent
        visible:        _isExpanded
        clip:           true
    }

    MouseArea {
        id:             pipMouseArea
        anchors.fill:   parent
        enabled:        _isExpanded
        preventStealing: true
        hoverEnabled:   true
        onClicked:  {
            if(item1._index!=2){
                _swapPip()
            }
        }
    }

    // MouseArea to drag in order to resize the PiP area
    MouseArea {
        id:             pipResize
        anchors.bottom:    parent.bottom
        anchors.right:  parent.right
        height:         25
        width:          25
        preventStealing: true
        cursorShape: Qt.PointingHandCursor

        property real initialX:     0
        property real initialWidth: 0

        // When we push the mouse button down, we un-anchor the mouse area to prevent a resizing loop
        onPressed: (mouse) => {
            pipResize.anchors.bottom = undefined // Top doesn't seem to 'detach'
            pipResize.anchors.right = undefined // This one works right, which is what we really need
            pipResize.initialX = mouse.x
            pipResize.initialWidth = _root.width
        }

        // When we let go of the mouse button, we re-anchor the mouse area in the correct position
        onReleased: {
            pipResize.anchors.bottom = _root.bottom
            pipResize.anchors.right = _root.right
        }

        // Drag
        onPositionChanged: (mouse) => {
            if (pipResize.pressed) {
                var parentWidth = _root.parent.width
                var newWidth = pipResize.initialWidth + mouse.x - pipResize.initialX
                if (newWidth < parentWidth * _maxSize && newWidth > parentWidth * _minSize) {
                    _pipSize = newWidth
                }
            }
        }
    }

    // Resize icon
    Image {
        source:         "/qmlimages/pipResize.svg"
        fillMode:       Image.PreserveAspectFit
        mipmap: true
        anchors.right:  parent.right
        anchors.bottom:    parent.bottom
        visible:        _isExpanded && pipMouseArea.containsMouse
        height:         25
        width:          25
        sourceSize.height:  height
        rotation:90
    }

    // Check min/max constraints on pip size when when parent is resized
    Connections {
        target: _root.parent

        function onWidthChanged() {
            if (!_componentComplete) {
                // Wait until first time setup is done
                return
            }
            var parentWidth = _root.parent.width
            if (_root.width > parentWidth * _maxSize) {
                _pipSize = parentWidth * _maxSize
            } else if (_root.width < parentWidth * _minSize) {
                _pipSize = parentWidth * _minSize
            }
        }
    }

    // Pip to Window
    Image {
        id:             popupPIP
        source:         "/qmlimages/PiP.svg"
        mipmap:         true
        fillMode:       Image.PreserveAspectFit
        anchors.left:   parent.left
        anchors.top:    parent.top
        visible: false
        //visible:        _isExpanded && pipMouseArea.containsMouse
        height:         25
        width:          25
        sourceSize.height:  height

        MouseArea {
            anchors.fill:   parent
            onClicked:      _pipOrWindowItem.pipState.state = _pipOrWindowItem.pipState.windowState
        }
    }

    Image {
        id:             hidePIP
        source:         "/qmlimages/pipHide.svg"
        mipmap:         true
        fillMode:       Image.PreserveAspectFit
        anchors.left:   parent.left
        anchors.bottom: parent.bottom
        visible: false
        //visible:        _isExpanded && pipMouseArea.containsMouse
        height:         25
        width:          25
        sourceSize.height:  height
        MouseArea {
            anchors.fill:   parent
            onClicked:      _root._setPipIsExpanded(false)
        }
    }

    Rectangle {
        id:                     showPip
        anchors.left :          parent.left
        anchors.bottom:         parent.bottom
        height:                 20
        width:                  20
        radius:                 3
        visible: false
        //visible:                !_isExpanded
        color:                  _fullItem.pipState.isDark ? Qt.rgba(0,0,0,0.75) : Qt.rgba(0,0,0,0.5)
        Image {
            width:              parent.width  * 0.75
            height:             parent.height * 0.75
            sourceSize.height:  height
            source:             "/qmlimages/buttonRight.svg"
            mipmap:             true
            fillMode:           Image.PreserveAspectFit
            anchors.verticalCenter:     parent.verticalCenter
            anchors.horizontalCenter:   parent.horizontalCenter
        }
        MouseArea {
            anchors.fill:   parent
            onClicked:      _root._setPipIsExpanded(true)
        }
    }
}
