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
import Qt5Compat.GraphicalEffects

Item {
    id: avatarRoot

    property string source: ""
    property string name: ""
    property bool showOrbit: false
    property bool showStatus: false
    property color ringColor: root.palette.text

    readonly property bool hasImage: avatarImage.status === Image.Ready

    implicitWidth: 64
    implicitHeight: 64

    onRingColorChanged: orbit.requestPaint()

    // Thin orbit ring drawn around the avatar.
    Canvas {
        id: orbit
        anchors.fill: parent
        visible: avatarRoot.showOrbit
        antialiasing: true
        transformOrigin: Item.Center

        RotationAnimation on rotation {
            from: 0
            to: 360
            duration: 120000
            loops: Animation.Infinite
            running: avatarRoot.showOrbit && root.animationsEnabled
        }
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var cx = width / 2
            var cy = height / 2
            var r = Math.min(cx, cy) - 1
            var c = avatarRoot.ringColor
            ctx.strokeStyle = Qt.rgba(c.r, c.g, c.b, 0.14)
            ctx.lineWidth = 1
            ctx.beginPath()
            ctx.arc(cx, cy, r, 0, Math.PI * 2)
            ctx.stroke()
            ctx.strokeStyle = Qt.rgba(c.r, c.g, c.b, 0.65)
            ctx.lineWidth = 1.4
            ctx.beginPath()
            ctx.arc(cx, cy, r, -Math.PI * 0.18, Math.PI * 0.34)
            ctx.stroke()
            var end = Math.PI * 0.34
            ctx.fillStyle = Qt.rgba(c.r, c.g, c.b, 0.85)
            ctx.beginPath()
            ctx.arc(cx + Math.cos(end) * r, cy + Math.sin(end) * r, Math.max(1.5, width * 0.018), 0, Math.PI * 2)
            ctx.fill()
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    Rectangle {
        id: circle
        anchors.fill: parent
        anchors.margins: avatarRoot.showOrbit ? Math.max(3, avatarRoot.width * 0.05) : 0
        radius: width / 2
        color: "#181818"
        border.width: 1
        border.color: "#4dffffff"
    }

    Text {
        anchors.centerIn: circle
        text: avatarRoot.name ? avatarRoot.name.charAt(0).toUpperCase() : "?"
        color: root.palette.text
        opacity: avatarRoot.hasImage ? 0 : 0.8
        font.pixelSize: circle.width * 0.38
        font.weight: Font.Light
        font.letterSpacing: 1
    }

    Image {
        id: avatarImage
        anchors.fill: circle
        source: avatarRoot.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        visible: false
    }

    Desaturate {
        id: desaturated
        anchors.fill: circle
        source: avatarImage
        desaturation: 1.0
        visible: false
    }

    Image {
        id: mask
        anchors.fill: circle
        source: Qt.resolvedUrl("../Assets/AvatarMask.svg")
        fillMode: Image.Stretch
        sourceSize: Qt.size(width, height)
        visible: true
        z: -1
    }

    OpacityMask {
        anchors.fill: circle
        source: desaturated
        maskSource: mask
        visible: avatarRoot.hasImage
    }

    Rectangle {
        visible: avatarRoot.showStatus
        width: Math.max(6, avatarRoot.width * 0.1)
        height: width
        radius: width / 2
        color: root.palette.text
        border.width: Math.max(1, width * 0.28)
        border.color: "#151515"
        anchors.right: circle.right
        anchors.bottom: circle.bottom
        anchors.rightMargin: -width * 0.08
        anchors.bottomMargin: -height * 0.08
    }
}
