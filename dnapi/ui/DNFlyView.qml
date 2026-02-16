import QtQuick 2.15

import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0


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

        MapView{
            id: map_view
            pipView: _pipView2
            _index:2
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
            onSwapped:(videoItem)=>{
                var fullItem = item1.isFull?item1:item2
                var pipItem = item1.isFull?item2:item1
                if(_pipView2.item1 == pipItem){
                    _pipView2.item1= fullItem
                    console.log("1")
                }else{
                    _pipView2.item2=fullItem
                    console.log("2")
                }
                if(fullItem._index!=2){
                    fullItem.videoItem.setBlockID(0)
                }
                if(pipItem._index!=2){
                    pipItem.videoItem.setBlockID(1)
                }

                //root.swapped(videoItem)
            }
        }

        PipView2{
            id: _pipView2
            sizeRatio: 9/16
            anchors.right:        parent.right
            anchors.bottom:         parent.bottom
            anchors.margins:        20
            item1:                  videoView0
            item2:                  map_view
            name: "his"
            z:1
            show:                   true

            onSwapped:(videoItem)=>{
                var fullItem = item1.isFull?item1:item2
                var pipItem = item1.isFull?item2:item1
                if(_pipView.item1 == pipItem){
                  _pipView.item1= fullItem
                }else{
                  _pipView.item2=fullItem
                }
                if(fullItem._index!=2){
                  fullItem.videoItem.setBlockID(0)
                }
                if(pipItem._index!=2){
                  pipItem.videoItem.setBlockID(2)
                }
                //root.swapped(videoItem)
            }
        }

    }







}
