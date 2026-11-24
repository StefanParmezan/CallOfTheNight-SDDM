//
// Call of the Night — SDDM theme
//
// Based on SDDM Sugar Candy by Marian Arlt (GPL-3.0-or-later)
// and the Makima-SDDM theme by Arnau029.
//
// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or any later version.
//

import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

Item {
    id: sessionButton
    height: root.font.pointSize * 1.8
    width: parent.width / 2
    anchors.horizontalCenter: parent.horizontalCenter

    property string textConstantSession
    property int loginButtonWidth

    property int currentIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0

    property var selectedSession: currentIndex
    property var exposeSession: sessionControl

    readonly property string currentName: sessionName(currentIndex)

    function sessionIsX11(index) {
        if (index < 0 || sessionModel.count === 0)
            return false
        var idx = sessionModel.index(index, 0)
        var type = ("" + sessionModel.data(idx, Qt.UserRole + 3)).toLowerCase()
        var name = ("" + sessionModel.data(idx, Qt.UserRole + 4)).toLowerCase()
        return type.indexOf("x11") >= 0 || name.indexOf("x11") >= 0
    }

    function sessionIsWayland(index) {
        if (index < 0 || sessionModel.count === 0)
            return false
        var idx = sessionModel.index(index, 0)
        var type = ("" + sessionModel.data(idx, Qt.UserRole + 3)).toLowerCase()
        var name = ("" + sessionModel.data(idx, Qt.UserRole + 4)).toLowerCase()
        return type.indexOf("wayland") >= 0 || name.indexOf("wayland") >= 0
    }

    function sessionIcon(index) {
        if (sessionIsX11(index))
            return "../Assets/SessionX11.svg"
        if (sessionIsWayland(index))
            return "../Assets/SessionWayland.svg"
        return "../Assets/SessionGeneric.svg"
    }

    function sessionName(index) {
        if (index < 0 || sessionModel.count === 0)
            return ""
        var idx = sessionModel.index(index, 0)
        var name = sessionModel.data(idx, Qt.UserRole + 4)
        if (!name)
            name = sessionModel.data(idx, Qt.UserRole + 6)
        if (!name) {
            var file = sessionModel.data(idx, Qt.UserRole + 2) || ""
            name = ("" + file).split("/").pop().replace(/\.desktop$/, "")
        }
        return name ? ("" + name) : ""
    }

    function choose(index) {
        if (index < 0)
            return
        currentIndex = index
        if (root.animationsEnabled)
            sessionSwitchFade.start()
        sessionMenu.close()
        password.forceActiveFocus()
    }

    SequentialAnimation {
        id: sessionSwitchFade

        NumberAnimation {
            target: sessionContent
            property: "opacity"
            from: 1
            to: 0.15
            duration: 90
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: sessionContent
            property: "opacity"
            from: 0.15
            to: 1
            duration: 170
            easing.type: Easing.OutCubic
        }
    }

    Button {
        id: sessionControl
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        padding: 0
        hoverEnabled: true
        Accessible.name: sessionLabel.text

        contentItem: Item {
            id: sessionContent
            opacity: 1

            Image {
                id: sessionIcon
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: root.font.pointSize * 0.95
                height: width
                source: Qt.resolvedUrl(sessionButton.sessionIcon(sessionButton.currentIndex))
                fillMode: Image.PreserveAspectFit
                opacity: 0.5
            }

            Text {
                id: sessionLabel
                anchors.left: sessionIcon.right
                anchors.leftMargin: root.font.pointSize * 0.35
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: (config.TranslateSession || (textConstantSession + ":")) + " " +
                      (sessionButton.currentName !== "" ? sessionButton.currentName : "…") + "  ▾"
                color: sessionControl.hovered || sessionControl.activeFocus ? root.palette.highlight : root.palette.text
                opacity: 0.72
                font.pointSize: root.font.pointSize * 0.78
                font.letterSpacing: root.font.pointSize * 0.03
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        background: Item {
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: sessionControl.activeFocus ? root.palette.highlight : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
            }
        }

        onClicked: sessionMenu.open()
        Keys.onReturnPressed: sessionMenu.open()
        Keys.onEnterPressed: sessionMenu.open()
        Keys.onTabPressed: systemButtons.powerItem.forceActiveFocus()
        KeyNavigation.up: loginButton
    }

    Popup {
        id: sessionMenu
        parent: sessionControl
        x: 0
        y: sessionControl.height + 2
        width: Math.max(sessionControl.width * 0.8, root.font.pointSize * 14)
        padding: 8
        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: config.RoundCorners || 0
            color: "#141414"
            border.width: 1
            border.color: "#3a3a3a"
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 8 * config.InterfaceShadowSize
                radius: 16 * config.InterfaceShadowSize
                samples: 33 * config.InterfaceShadowSize
                cached: true
                color: Qt.hsla(0,0,0,config.InterfaceShadowOpacity)
            }
        }

        contentItem: ListView {
            id: sessionList
            implicitHeight: Math.min(contentHeight, root.font.pointSize * 14)
            model: sessionModel
            currentIndex: sessionButton.currentIndex
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollIndicator.vertical: ScrollIndicator { }

            delegate: ItemDelegate {
                width: ListView.view.width
                height: root.font.pointSize * 2.8
                hoverEnabled: true
                highlighted: ListView.isCurrentItem
                Accessible.name: sessionButton.sessionName(index)

                contentItem: Item {
                    Image {
                        id: delegateIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: root.font.pointSize * 0.9
                        height: width
                        source: Qt.resolvedUrl(sessionButton.sessionIcon(index))
                        fillMode: Image.PreserveAspectFit
                        opacity: 0.45
                    }

                    Text {
                        anchors.left: delegateIcon.right
                        anchors.leftMargin: 8
                        anchors.right: checkMark.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: sessionButton.sessionName(index)
                        color: root.palette.text
                        font.pointSize: root.font.pointSize * 0.8
                        font.letterSpacing: root.font.pointSize * 0.03
                        elide: Text.ElideRight
                    }

                    Image {
                        id: checkMark
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: root.font.pointSize * 1.05
                        height: width
                        source: Qt.resolvedUrl("../Assets/Check.svg")
                        fillMode: Image.PreserveAspectFit
                        visible: index === sessionButton.currentIndex
                        opacity: 0.78
                    }
                }

                background: Rectangle {
                    radius: config.RoundCorners || 0
                    color: parent.hovered || parent.highlighted ? "#242424" : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                onClicked: sessionButton.choose(index)
            }

            Keys.onReturnPressed: sessionButton.choose(currentIndex)
            Keys.onEnterPressed: sessionButton.choose(currentIndex)
            Keys.onEscapePressed: sessionMenu.close()
        }

        onOpened: {
            sessionList.currentIndex = sessionButton.currentIndex
            sessionList.forceActiveFocus()
        }
        onClosed: password.forceActiveFocus()
    }
}
