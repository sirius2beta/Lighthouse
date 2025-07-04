﻿pragma Singleton
import QtQuick 2.15

QtObject {
    readonly property int width: 1920
    readonly property int height: 1080
    property real voltLL:19
    property bool voltAlarm: false
    property real cabinTU: 50
    property bool cabinTAlarm: false
    property real depthLL: 50
    property real rssiLL: -100
    property bool rssiAlarm: false
    property bool depthAlarm: false


    property string relativeFontDirectory: "fonts"

    /* Edit this comment to add your custom font */
    readonly property font font: Qt.font({
                                             family: "roboto",
                                             pixelSize: Qt.application.font.pixelSize
                                         })
    readonly property font blackfont: Qt.font({
                                             family: "roboto black",
                                             pixelSize: Qt.application.font.pixelSize
                                         })
    readonly property font largeFont: Qt.font({
                                                  family: Qt.application.font.family,
                                                  pixelSize: Qt.application.font.pixelSize * 1.6
                                              })

    readonly property color backgroundColor: "#c2c2c2"




}
