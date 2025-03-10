import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0

Popup {
        id:root
        width:600
        height:400
        parent: Overlay.overlay
        padding: 0
        anchors.centerIn:   parent
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        onClosed: {
            Qt.inputMethod.hide()
            DeNovoViewer.boatManager.getBoatbyIndex(boatListView.currentIndex).PIP = pipEdit.text
            DeNovoViewer.boatManager.getBoatbyIndex(boatListView.currentIndex).SIP = sipEdit.text
            root.destroy()
        }
}
