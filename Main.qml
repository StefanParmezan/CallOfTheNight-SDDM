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
import "Components"

Pane {
    id: root

    height: config.ScreenHeight || Screen.height
    width: config.ScreenWidth || Screen.width

    LayoutMirroring.enabled: config.ForceRightToLeft == "true" ? true : Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    padding: config.ScreenPadding
    palette.button: "transparent"
    palette.highlight: config.AccentColor
    palette.text: config.MainColor
    palette.buttonText: config.MainColor
    palette.window: config.BackgroundColor

    font.family: config.Font
    font.pointSize: config.FontSize !== "" ? Number(config.FontSize) : Math.max(10, parseInt(height / 80))
    focus: true

    property bool leftleft: config.HaveFormBackground == "true" &&
                            config.PartialBlur == "false" &&
                            config.FormPosition == "left" &&
                            config.BackgroundImageHAlignment == "left"

    property bool leftcenter: config.HaveFormBackground == "true" &&
                              config.PartialBlur == "false" &&
                              config.FormPosition == "left" &&
                              config.BackgroundImageHAlignment == "center"

    property bool rightright: config.HaveFormBackground == "true" &&
                              config.PartialBlur == "false" &&
                              config.FormPosition == "right" &&
                              config.BackgroundImageHAlignment == "right"

    property bool rightcenter: config.HaveFormBackground == "true" &&
                               config.PartialBlur == "false" &&
                               config.FormPosition == "right" &&
                               config.BackgroundImageHAlignment == "center"

    // Smooth left-panel blur: the blurred copy fades into the sharp background.
    readonly property bool softLeftBlur: config.PartialBlur == "true" &&
                                        config.FullBlur != "true" &&
                                        config.FormPosition == "left"
    readonly property real blurPanelFraction: {
        var v = parseFloat(config.BlurPanelWidth)
        return isNaN(v) ? 0.88 : Math.max(0.7, Math.min(1.0, v))
    }
    readonly property real blurPanelWidth: Math.min(root.width, form.width * blurPanelFraction)
    readonly property real blurPanelOffset: Math.max(0, (form.width - blurPanelWidth) / 2)
    readonly property real blurFadeWidth: {
        var v = parseFloat(config.BlurFadeWidth)
        return Math.round(root.font.pointSize * (isNaN(v) ? 6 : Math.max(0, v)))
    }
    readonly property real blurFadeFraction: blurPanelWidth > 0 ? Math.min(0.45, blurFadeWidth / blurPanelWidth) : 0.15
    readonly property real softPanelAlpha: {
        var v = parseFloat(config.FormPanelOpacity)
        return isNaN(v) ? 0.62 : Math.max(0, Math.min(1, v))
    }
    readonly property color softPanelColor: Qt.rgba(root.palette.window.r, root.palette.window.g, root.palette.window.b, root.softPanelAlpha)
    readonly property color softPanelClear: Qt.rgba(root.palette.window.r, root.palette.window.g, root.palette.window.b, 0.0)
    readonly property bool animationsEnabled: config.AnimationsEnabled != "false"
    property bool backgroundFallback: false

    Component.onCompleted: {
        if (animationsEnabled) {
            formIntro.start()
            introFade.start()
        } else {
            introOverlay.visible = false
            form.opacity = 1
            formIntroShift.y = 0
        }
    }

    ParallelAnimation {
        id: formIntro

        NumberAnimation {
            target: form
            property: "opacity"
            from: 0
            to: 1
            duration: 700
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: formIntroShift
            property: "y"
            from: root.font.pointSize * 1.2
            to: 0
            duration: 800
            easing.type: Easing.OutCubic
        }
    }

    NumberAnimation {
        id: introFade

        target: introOverlay
        property: "opacity"
        from: 1
        to: 0
        duration: 900
        easing.type: Easing.InOutSine
        onStopped: introOverlay.visible = false
    }

    Rectangle {
        id: introOverlay
        anchors.fill: parent
        color: "black"
        opacity: root.animationsEnabled ? 1 : 0
        visible: root.animationsEnabled
        z: 20
    }

    Item {
        id: sizeHelper

        anchors.fill: parent
        height: parent.height
        width: parent.width

        Rectangle {
            id: tintLayer
            anchors.fill: parent
            width: parent.width
            height: parent.height
            color: "black"
            opacity: config.DimBackgroundImage
            z: 1
        }

        Rectangle {
            id: formBackground
            anchors.fill: form
            anchors.centerIn: form
            color: root.palette.window
            visible: config.HaveFormBackground == "true" && !root.softLeftBlur
            opacity: config.PartialBlur == "true" ? root.softPanelAlpha : 1
            z: 1
        }

        // The dark form tint fades out together with the blur.
        Rectangle {
            id: formBackgroundFade
            x: 0
            y: 0
            width: root.blurPanelWidth
            height: parent.height
            visible: config.HaveFormBackground == "true" && root.softLeftBlur
            z: 1
            gradient: Gradient {
                GradientStop { position: 0.0; color: root.softPanelColor }
                GradientStop { position: 1.0 - root.blurFadeFraction; color: root.softPanelColor }
                GradientStop { position: 1.0; color: root.softPanelClear }
            }
        }

        // Very subtle film grain over the frosted panel.
        Image {
            id: panelGrainSource

            x: 0
            y: 0
            width: root.blurPanelWidth
            height: parent.height
            source: Qt.resolvedUrl("Assets/Noise.png")
            fillMode: Image.Tile
            visible: false
        }

        Rectangle {
            id: panelGrainMask

            x: 0
            y: 0
            width: root.blurPanelWidth
            height: parent.height
            visible: false
            gradient: Gradient {
                GradientStop { position: 0.0; color: "white" }
                GradientStop { position: 1.0 - root.blurFadeFraction; color: "white" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        OpacityMask {
            x: 0
            y: 0
            width: root.blurPanelWidth
            height: parent.height
            source: panelGrainSource
            maskSource: panelGrainMask
            opacity: 0.03
            visible: root.softLeftBlur
            z: 1
        }

        LoginForm {
            id: form

            height: virtualKeyboard.state == "visible" ? parent.height - virtualKeyboard.implicitHeight : parent.height
            width: parent.width / 2.5
            anchors.horizontalCenter: config.FormPosition == "center" ? parent.horizontalCenter : undefined
            anchors.left: config.FormPosition == "left" ? parent.left : undefined
            anchors.leftMargin: root.softLeftBlur ? -root.blurPanelOffset : 0
            anchors.right: config.FormPosition == "right" ? parent.right : undefined
            virtualKeyboardActive: virtualKeyboard.state == "visible" ? true : false
            opacity: root.animationsEnabled ? 0 : 1
            transform: Translate { id: formIntroShift; y: root.animationsEnabled ? root.font.pointSize * 1.2 : 0 }
            z: 1
        }

        Button {
            id: vkb
            onClicked: virtualKeyboard.switchState()
            visible: virtualKeyboard.status == Loader.Ready && config.ForceHideVirtualKeyboardButton == "false"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: implicitHeight
            anchors.horizontalCenter: form.horizontalCenter
            z: 1
            contentItem: Text {
                text: config.TranslateVirtualKeyboardButton || "Виртуальная клавиатура"
                color: parent.visualFocus ? palette.highlight : palette.text
                font.pointSize: root.font.pointSize * 0.8
                opacity: 0.7
            }
            background: Rectangle {
                id: vkbbg
                color: "transparent"
            }
        }

        Loader {
            id: virtualKeyboard
            source: "Components/VirtualKeyboard.qml"
            state: "hidden"
            property bool keyboardActive: item ? item.active : false
            onKeyboardActiveChanged: keyboardActive ? state = "visible" : state = "hidden"
            width: parent.width
            z: 1
            function switchState() { state = state == "hidden" ? "visible" : "hidden" }
            states: [
                State {
                    name: "visible"
                    PropertyChanges {
                        target: form
                        systemButtonVisibility: false
                        clockVisibility: false
                    }
                    PropertyChanges {
                        target: virtualKeyboard
                        y: root.height - virtualKeyboard.height
                        opacity: 1
                    }
                },
                State {
                    name: "hidden"
                    PropertyChanges {
                        target: virtualKeyboard
                        y: root.height - root.height/4
                        opacity: 0
                    }
                }
            ]
            transitions: [
                Transition {
                    from: "hidden"
                    to: "visible"
                    SequentialAnimation {
                        ScriptAction {
                            script: {
                                virtualKeyboard.item.activated = true;
                                Qt.inputMethod.show();
                            }
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: virtualKeyboard
                                property: "y"
                                duration: 100
                                easing.type: Easing.OutQuad
                            }
                            OpacityAnimator {
                                target: virtualKeyboard
                                duration: 100
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                },
                Transition {
                    from: "visible"
                    to: "hidden"
                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: virtualKeyboard
                                property: "y"
                                duration: 100
                                easing.type: Easing.InQuad
                            }
                            OpacityAnimator {
                                target: virtualKeyboard
                                duration: 100
                                easing.type: Easing.InQuad
                            }
                        }
                        ScriptAction {
                            script: {
                                Qt.inputMethod.hide();
                            }
                        }
                    }
                }
            ]
        }

        Image {
            id: backgroundImage

            height: parent.height
            width: config.HaveFormBackground == "true" && config.FormPosition != "center" && config.PartialBlur != "true" ? parent.width - formBackground.width : parent.width
            anchors.left: leftleft ||
                          leftcenter ?
                                formBackground.right : undefined

            anchors.right: rightright ||
                           rightcenter ?
                                formBackground.left : undefined

            horizontalAlignment: config.BackgroundImageHAlignment == "left" ?
                                 Image.AlignLeft :
                                 config.BackgroundImageHAlignment == "right" ?
                                 Image.AlignRight : Image.AlignHCenter

            verticalAlignment: config.BackgroundImageVAlignment == "top" ?
                               Image.AlignTop :
                               config.BackgroundImageVAlignment == "bottom" ?
                               Image.AlignBottom : Image.AlignVCenter

            source: config.background || config.Background
            fillMode: config.ScaleImageCropped == "true" ? Image.PreserveAspectCrop : Image.PreserveAspectFit
            asynchronous: true
            cache: true
            clip: true
            mipmap: true
            onStatusChanged: {
                if (status === Image.Error && !root.backgroundFallback) {
                    root.backgroundFallback = true
                    source = Qt.resolvedUrl("Backgrounds/background-eyes.png")
                }
            }
        }

        MouseArea {
            anchors.fill: backgroundImage
            onClicked: parent.forceActiveFocus()
        }

        // Soft blurred copy for the left panel with a gradient fade on the right.
        ShaderEffectSource {
            id: softBlurSource

            sourceItem: backgroundImage
            x: 0
            y: 0
            width: root.blurPanelWidth
            height: parent.height
            sourceRect: Qt.rect(0, 0, width, height)
            visible: false
            live: true
        }

        GaussianBlur {
            id: softBlur

            x: 0
            y: 0
            width: root.blurPanelWidth
            height: parent.height
            source: softBlurSource
            radius: config.BlurRadius
            samples: config.BlurRadius * 2 + 1
            cached: true
            visible: false
        }

        Rectangle {
            id: softBlurMask

            x: 0
            y: 0
            width: root.blurPanelWidth
            height: parent.height
            visible: false
            gradient: Gradient {
                GradientStop { position: 0.0; color: "white" }
                GradientStop { position: 1.0 - root.blurFadeFraction; color: "white" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        OpacityMask {
            x: 0
            y: 0
            width: root.blurPanelWidth
            height: parent.height
            source: softBlur
            maskSource: softBlurMask
            visible: root.softLeftBlur
        }

        ShaderEffectSource {
            id: blurMask

            sourceItem: backgroundImage
            width: form.width
            height: parent.height
            anchors.centerIn: form
            sourceRect: Qt.rect(x,y,width,height)
            visible: config.FullBlur == "true" || (config.PartialBlur == "true" && !root.softLeftBlur) ? true : false
        }

        GaussianBlur {
            id: blur

            height: parent.height
            width: config.FullBlur == "true" ? parent.width : form.width
            source: config.FullBlur == "true" ? backgroundImage : blurMask
            radius: config.BlurRadius
            samples: config.BlurRadius * 2 + 1
            cached: true
            anchors.centerIn: config.FullBlur == "true" ? parent : form
            visible: config.FullBlur == "true" || (config.PartialBlur == "true" && !root.softLeftBlur) ? true : false
        }

        // Small title card in the bottom right corner.
        Column {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: root.font.pointSize * 1.7
            anchors.bottomMargin: root.font.pointSize * 1.25
            spacing: root.font.pointSize * 0.1
            z: 1
            visible: config.ShowTitleCard != "false"

            Text {
                anchors.right: parent.right
                text: "CALL OF THE NIGHT"
                color: root.palette.text
                opacity: 0.42
                font.family: root.font.family
                font.pointSize: root.font.pointSize * 0.52
                font.letterSpacing: root.font.pointSize * 0.2
            }
            Text {
                anchors.right: parent.right
                text: "よふかしのうた"
                color: root.palette.text
                opacity: 0.28
                font.family: "Noto Sans CJK JP"
                font.pointSize: root.font.pointSize * 0.55
                font.letterSpacing: root.font.pointSize * 0.1
            }
        }
    }
}
