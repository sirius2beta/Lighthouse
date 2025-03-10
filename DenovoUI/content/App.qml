// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 2.15
import QtQuick.Window 2.15
import DenovoUI 1.0

Window {
    id: window
    width: 1440
    height: 900

    visible: true
    title: "DenovoUI"

    Rectangle{
        anchors.fill: parent
        color: "#1a1a1c"
    }

    StatusView{
        id: statusView
        width: 200
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: statusBar.top
    }

    ControlView{
        id: controlView
        x: 1080
        width: 300
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: statusBar.top
    }

    StatusBar{
        id: statusBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height:20

    }

    CentralView{
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: controlView.left
        anchors.bottom: statusBar.top
    }

}

