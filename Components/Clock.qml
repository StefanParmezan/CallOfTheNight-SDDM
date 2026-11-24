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

Column {
    id: clock
    spacing: 0
    width: parent.width / 2

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: text !== ""
        text: config.HeaderText
        color: root.palette.text
        opacity: 0.92
        font.pointSize: root.font.pointSize * 0.68
        font.weight: Font.Medium
        font.letterSpacing: root.font.pointSize * 0.24
        font.capitalization: Font.AllUppercase
        renderType: Text.QtRendering
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: text !== ""
        text: config.HeaderSubtext || ""
        color: root.palette.text
        opacity: 0.4
        font.family: "Noto Sans CJK JP"
        font.pointSize: root.font.pointSize * 0.58
        font.letterSpacing: root.font.pointSize * 0.22
        renderType: Text.QtRendering
    }

    Item {
        width: 1
        height: root.font.pointSize * 1.15
    }

    Label {
        id: timeLabel
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: root.font.pointSize * 3.35
        font.weight: Font.Light
        font.letterSpacing: root.font.pointSize * 0.06
        color: root.palette.text
        renderType: Text.QtRendering
        function updateTime() {
            text = new Date().toLocaleTimeString(Qt.locale(config.Locale), config.HourFormat == "long" ? Locale.LongFormat : config.HourFormat !== "" ? config.HourFormat : Locale.ShortFormat)
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.font.pointSize * 2.4
        height: 1
        color: root.palette.text
        opacity: 0.28
    }

    Item {
        width: 1
        height: root.font.pointSize * 0.75
    }

    Label {
        id: dateLabel
        anchors.horizontalCenter: parent.horizontalCenter
        color: root.palette.text
        opacity: 0.55
        font.pointSize: root.font.pointSize * 0.62
        font.letterSpacing: root.font.pointSize * 0.1
        renderType: Text.QtRendering
        function updateTime() {
            text = new Date().toLocaleDateString(Qt.locale(config.Locale), config.DateFormat == "short" ? Locale.ShortFormat : config.DateFormat !== "" ? config.DateFormat : Locale.LongFormat)
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            dateLabel.updateTime()
            timeLabel.updateTime()
        }
    }

    Component.onCompleted: {
        dateLabel.updateTime()
        timeLabel.updateTime()
    }
}
