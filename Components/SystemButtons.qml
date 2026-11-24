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
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

Item {
    id: systemButtons

    implicitWidth: root.font.pointSize * 4
    implicitHeight: root.font.pointSize * 4

    property var exposedSession
    property var powerItem: powerButton

    readonly property var actions: [
        {
            key: "suspend",
            label: config.TranslateSuspend || textConstants.suspend,
            icon: "Suspend",
            available: sddm.canSuspend
        },
        {
            key: "hibernate",
            label: config.TranslateHibernate || textConstants.hibernate,
            icon: "Hibernate",
            available: sddm.canHibernate
        },
        {
            key: "reboot",
            label: config.TranslateReboot || textConstants.reboot,
            icon: "Reboot",
            available: sddm.canReboot
        },
        {
            key: "shutdown",
            label: config.TranslateShutdown || textConstants.shutdown,
            icon: "Shutdown",
            available: sddm.canPowerOff
        }
    ]

    function runAction(index) {
        var action = actions[index]
        if (!action)
            return
        powerMenu.close()
        if (action.key === "suspend")
            sddm.suspend()
        else if (action.key === "hibernate")
            sddm.hibernate()
        else if (action.key === "reboot")
            sddm.reboot()
        else if (action.key === "shutdown")
            sddm.powerOff()
    }

    Button {
        id: powerButton

        width: root.font.pointSize * 5.2
        height: width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: root.font.pointSize * 0.8
        hoverEnabled: true
        visible: config.ForceHideSystemButtons != "true"
        Accessible.name: config.TranslatePower || "Питание"

        contentItem: Column {
            anchors.centerIn: parent
            spacing: root.font.pointSize * 0.25

            Image {
                width: root.font.pointSize * 1.4
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                source: Qt.resolvedUrl("../Assets/Shutdown.svg")
                fillMode: Image.PreserveAspectFit
                opacity: powerButton.hovered || powerButton.activeFocus ? 0.95 : 0.55
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: config.TranslatePower || "Питание"
                color: root.palette.text
                opacity: powerButton.hovered || powerButton.activeFocus ? 0.7 : 0.42
                font.pointSize: root.font.pointSize * 0.6
                font.letterSpacing: root.font.pointSize * 0.03
            }
        }

        background: Item {}

        onClicked: powerMenu.open()
        Keys.onReturnPressed: powerMenu.open()
        Keys.onEnterPressed: powerMenu.open()
        KeyNavigation.up: exposedSession
    }

    Popup {
        id: powerMenu

        parent: powerButton
        x: (powerButton.width - width) / 2
        y: -height - 4
        width: root.font.pointSize * 15
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
                verticalOffset: -8 * config.InterfaceShadowSize
                radius: 16 * config.InterfaceShadowSize
                samples: 33 * config.InterfaceShadowSize
                cached: true
                color: Qt.hsla(0,0,0,config.InterfaceShadowOpacity)
            }
        }

        contentItem: ListView {
            id: powerList

            implicitHeight: Math.min(contentHeight, root.font.pointSize * 14)
            model: systemButtons.actions
            currentIndex: 0
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollIndicator.vertical: ScrollIndicator { }

            delegate: ItemDelegate {
                width: ListView.view.width
                height: root.font.pointSize * 2.8
                hoverEnabled: true
                highlighted: ListView.isCurrentItem
                Accessible.name: modelData.label
                opacity: modelData.available ? 1 : 0.32

                contentItem: Item {
                    Image {
                        id: powerActionIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: root.font.pointSize * 1.15
                        height: width
                        source: Qt.resolvedUrl("../Assets/" + modelData.icon + ".svg")
                        fillMode: Image.PreserveAspectFit
                        opacity: 0.55
                    }

                    Text {
                        anchors.left: powerActionIcon.right
                        anchors.leftMargin: root.font.pointSize * 0.6
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.label
                        color: root.palette.text
                        opacity: 0.78
                        font.pointSize: root.font.pointSize * 0.82
                        font.letterSpacing: root.font.pointSize * 0.03
                        elide: Text.ElideRight
                    }
                }

                background: Rectangle {
                    radius: config.RoundCorners || 0
                    color: parent.hovered || parent.highlighted ? "#242424" : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                onClicked: systemButtons.runAction(index)
            }

            Keys.onReturnPressed: systemButtons.runAction(currentIndex)
            Keys.onEnterPressed: systemButtons.runAction(currentIndex)
            Keys.onEscapePressed: powerMenu.close()
        }

        onOpened: {
            powerList.currentIndex = 0
            powerList.forceActiveFocus()
        }
        onClosed: powerButton.forceActiveFocus()
    }
}
