import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0
import DeNovoViewer.Control 1.0

Item {
    Component{
        id: editBoatDialog
        EditBoatDialog{

        }
    }
    id: _root
    height:300
    width:300
    Layout.preferredWidth: 300
    Layout.fillHeight: true
    Layout.alignment: Qt.AlignLeft
    property int boatNo: 0

    Rectangle{
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        radius:5
        color: "#222222"
        opacity: 100
        border.width: 0
        border.color: "#dddddd"

        Rectangle{
            id: _title
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 2

            height:35
            color: "#191919"

            Text{
                anchors.fill: parent
                verticalAlignment: Qt.AlignVCenter
                leftPadding: 2
                font.family: "Roboto"
                font.pixelSize: 16
                text:" Boat Settings"
                color:"white"
            }
            Button {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                id: close_button
                text: ""
                topInset: 0
                bottomInset: 0
                height:30
                width:30
                property bool activate: false
                background: Rectangle {
                    color: parent.down ? "#99333333" : "#00000000"
                    //border.color: "#26282a"
                    //border.width: 1
                    implicitWidth: 45
                    implicitHeight: 45
                    radius: 4
                    Rectangle{
                        anchors.fill: parent
                        radius:4
                        anchors.margins: 5
                        color:"#00999900"
                    }

                    Image{
                        id: img3
                        anchors.margins: 5
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.left: parent.left
                        fillMode: Image.PreserveAspectFit

                        source: "qrc:/res/close.png"
                    }
                }
                onClicked: {
                    _root.parent.source = ""
                }
            }
        }
        ColumnLayout{
            anchors.top: _title.bottom
            anchors.left: parent.left
            anchors.right:  parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10
            RowLayout{
                id: boat_name_layout
                Text{
                    text:"boat name"
                    Layout.preferredWidth: 100
                    color:"#ffffff"
                    font.pixelSize: 14
                }
                TextField {
                    id: boat_name_edit
                    Layout.fillWidth: true
                    selectByMouse: true
                    text: DeNovoViewer.boatManager.getBoatbyIndex(boatNo).name
                    font.family: "Segoe UI"
                }
            }
            RowLayout{
                id: pip_layout
                Text{
                    text:"priamary IP"
                    color:"#ffffff"
                    font.pixelSize: 14
                    Layout.preferredWidth: 100
                }
                TextField {
                    id: boat_PIP_edit
                    Layout.fillWidth: true
                    selectByMouse: true
                    text: DeNovoViewer.boatManager.getBoatbyIndex(boatNo).PIP
                    font.family: "Segoe UI"
                }
            }
            RowLayout{
                id: sip_layout
                Text{
                    text:"secondary IP"
                    color:"#ffffff"
                    font.pixelSize: 14
                    Layout.preferredWidth: 100
                }
                TextField {
                    id: boat_SIP_edit
                    Layout.fillWidth: true
                    selectByMouse: true
                    text: DeNovoViewer.boatManager.getBoatbyIndex(boatNo).SIP
                    font.family: "Segoe UI"
                }
            }
            RowLayout{
                Item{
                    Layout.fillWidth: true
                }

                DNSquareButton{
                    text: "save"
                    onClicked: {
                        DeNovoViewer.boatManager.getBoatbyIndex(boatNo).PIP = boat_PIP_edit.text
                        DeNovoViewer.boatManager.getBoatbyIndex(boatNo).SIP = boat_SIP_edit.text
                        DeNovoViewer.boatManager.getBoatbyIndex(boatNo).name = boat_name_edit.text

                    }
                }
            }

            Rectangle{
                id: _proxy_title
                Layout.fillWidth: true
                color: "#191919"
                height: 35
                Text{
                    anchors.fill: parent
                    verticalAlignment: Qt.AlignVCenter
                    leftPadding: 2
                    font.family: "Roboto"
                    font.pixelSize: 16
                    text:" Mavlink轉發"
                    color:"white"
                }
            }

            RowLayout {
                Layout.fillWidth: true

                TextField {
                    id: addInput
                    Layout.fillWidth: true
                    placeholderText: "例如 127.0.0.1:8080"
                    selectByMouse: true

                    // 按下 Enter 也可以直接觸發新增
                    onAccepted: addButton.clicked()
                }

                DNSquareButton {
                    id: addButton
                    text: "新增"
                    // 只有當輸入框有文字時才允許點擊
                    enabled: addInput.text.trim() !== ""
                    onClicked: {
                        DeNovoViewer.networkManager.addForwardConnection(addInput.text.trim())
                        addInput.clear() // 新增完後清空輸入框
                    }
                }
            }

            // 分隔線
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#cccccc"
            }

            // ==========================================
            // 2. 底部：連線列表區塊
            // ==========================================
            ListView {
                id: connectionList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2

                // 綁定 C++ 屬性
                model: DeNovoViewer.networkManager.forwardConnections

                // 當列表為空時的提示文字
                Text {
                    anchors.centerIn: parent
                    text: "目前沒有連線"
                    color: "#999999"
                    visible: connectionList.count === 0
                }

                delegate: Item {
                    id: _delegate
                    width: ListView.view.width
                    height: 60

                    // 自訂屬性來控制目前的狀態是否為「編輯中」
                    property bool isEditing: false

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.color: isEditing ? "#2196F3" : "#e0e0e0"
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 5
                            spacing: 5

                            // 1. 顯示/編輯 IP 的輸入框
                            TextField {
                                id: editInput
                                Layout.fillHeight: true
                                Layout.fillWidth: true // 它會自己把剩下的寬度全部吃掉
                                text: modelData
                                readOnly: !_delegate.isEditing

                                background: Rectangle {
                                    color: "transparent"
                                }
                            }

                            // 2. 編輯/儲存按鈕
                            DNIconButton {
                                // 【關鍵修正 1】：在 Layout 裡，一律使用 Layout.preferredHeight 而不是 implicitHeight
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                iconSource: _delegate.isEditing ? "qrc:/res/check.svg" : "qrc:/res/edit_square.svg"
                                onClicked: {
                                    if (_delegate.isEditing) {
                                        let newAddress = editInput.text.trim()
                                        if (newAddress !== "" && newAddress !== modelData) {
                                            DeNovoViewer.networkManager.editForwardConnection(index, newAddress)
                                        } else {
                                            editInput.text = modelData
                                        }
                                    } else {
                                        editInput.forceActiveFocus()
                                    }
                                    _delegate.isEditing = !_delegate.isEditing
                                }
                            }

                            // 3. 船圖示刪除按鈕
                            DNIconButton {
                                // 【關鍵修正 2】：絕對鎖死尺寸，天王老子來了也不能拉長
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30

                                // 【關鍵修正 3】：強制垂直置中，避免被 RowLayout 往上下扯
                                Layout.alignment: Qt.AlignVCenter

                                iconSource: "qrc:/res/delete.svg"
                                onClicked: DeNovoViewer.networkManager.removeForwardConnection(modelData)
                            }

                            // 【關鍵修正 4】：把最下面的 Item { Layout.fillWidth: true } 刪掉了！
                        }
                    }
                }

                // 加入滾動動畫，讓列表更新時視覺更滑順
                add: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 } }
                remove: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 } }
            }

            Item{
                Layout.fillHeight: true
            }
        }
    }



}


