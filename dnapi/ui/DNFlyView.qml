import QtQuick 2.15

import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0
import DenovoUI 1.0

Item {
    id: root
    signal swapped(videoItem: VideoItem)

    Item{
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        DNVideoView{
            id: videoView0
            pipView: _pipView
            _index:0
            videoObjectName: "videoContent0"
            display_no: 1
        }

        DNVideoView{
            id: videoView1
            pipView: _pipView
            _index: 1
            videoObjectName: "videoContent1"
            display_no: 2
        }




        PipView{
            id: _pipView
            sizeRatio: 9/16
            anchors.left:        parent.left
            anchors.top:         parent.top
            anchors.margins:        10
            item1:                  videoView0
            item2:                  videoView1
            name: "his"
            z:1
            show:                   true
            onSwapped: (videoItem) => root.swapped(videoItem)
        }
    }







}
