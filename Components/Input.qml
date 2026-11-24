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

Column {
    id: inputContainer
    Layout.fillWidth: true

    property var exposeSession: sessionSelect.exposeSession
    property bool failed
    property bool loginPending: false
    property string pendingLoginUser: ""
    property string pendingLoginPassword: ""
    property int pendingSession: 0

    function attemptLogin() {
        if (loginPending || !loginButton.enabled)
            return

        var loginName = userProfile.loginUserName || username.text
        if (config.AllowBadUsernames == "false")
            loginName = loginName.toLowerCase()

        pendingLoginUser = loginName
        pendingLoginPassword = password.text
        pendingSession = sessionSelect.selectedSession
        loginPending = true
        loginRecoverTimer.start()

        if (root.animationsEnabled) {
            loginFadeOut.start()
            loginTimer.start()
        } else {
            formContainer.opacity = 1
            doLogin()
        }
    }

    function doLogin() {
        var user = pendingLoginUser
        var pass = pendingLoginPassword
        var session = pendingSession
        pendingLoginPassword = ""
        sddm.login(user, pass, session)
    }

    NumberAnimation {
        id: loginFadeOut
        target: formContainer
        property: "opacity"
        to: 0
        duration: 180
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: loginFadeBack
        target: formContainer
        property: "opacity"
        from: 0
        to: 1
        duration: 260
        easing.type: Easing.OutCubic
    }

    Item {
        id: userProfile
        height: root.font.pointSize * 12.6
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: root.animationsEnabled ? 0 : 1
        transform: Translate { id: profileIntroShift; y: root.animationsEnabled ? root.font.pointSize * 0.6 : 0 }

        property int userIndex: config.ForceLastUser == "true" && userModel.lastIndex >= 0 ? userModel.lastIndex : (userModel.count > 0 ? 0 : -1)
        property var userIndexData: userIndex >= 0 ? userModel.index(userIndex, 0) : null
        property string userName: userIndexData !== null ? (userModel.data(userIndexData, Qt.UserRole + 1) || "") : ""
        property string userRealName: userIndexData !== null ? (userModel.data(userIndexData, Qt.UserRole + 2) || "") : ""
        property string displayName: userRealName !== "" ? userRealName : userName
        property string loginUserName: ""
        property string accountsIcon: userName !== "" ? "file:///var/lib/AccountsService/icons/" + encodeURIComponent(userName) : ""

        function syncUserName() {
            loginUserName = userName
            username.text = displayName
        }

        function chooseUser(index) {
            if (index < 0)
                return
            userIndex = index
            syncUserName()
            if (root.animationsEnabled)
                userSwitchFade.start()
            password.text = ""
            userMenu.close()
            password.forceActiveFocus()
        }

        Component.onCompleted: {
            syncUserName()
            profileIntro.start()
        }
        onUserNameChanged: Qt.callLater(syncUserName)

        SequentialAnimation {
            id: profileIntro

            PauseAnimation { duration: 250 }
            ParallelAnimation {
                NumberAnimation {
                    target: userProfile
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 550
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: profileIntroShift
                    property: "y"
                    from: root.font.pointSize * 0.6
                    to: 0
                    duration: 650
                    easing.type: Easing.OutCubic
                }
            }
        }

        SequentialAnimation {
            id: userSwitchFade

            NumberAnimation {
                target: userProfile
                property: "opacity"
                from: 1
                to: 0.15
                duration: 90
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: userProfile
                property: "opacity"
                from: 0.15
                to: 1
                duration: 170
                easing.type: Easing.OutCubic
            }
        }

        UserAvatar {
            id: avatar
            width: root.font.pointSize * 6.8
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            source: userProfile.accountsIcon
            name: username.text || userProfile.userName
            showOrbit: true
            showStatus: true

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: userMenu.open()
            }
        }

        Text {
            anchors.fill: username
            text: config.TranslatePlaceholderUsername || textConstants.userName
            visible: username.text.length === 0
            color: "#8a8a8a"
            opacity: 0.8
            font: username.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            renderType: Text.QtRendering
        }

        TextField {
            id: username
            width: parent.width
            height: root.font.pointSize * 2.8
            anchors.top: avatar.bottom
            anchors.topMargin: root.font.pointSize * 0.8
            anchors.horizontalCenter: parent.horizontalCenter
            text: ""
            padding: 0
            topPadding: 0
            bottomPadding: 0
            font.capitalization: Font.MixedCase
            font.pointSize: root.font.pointSize * 1.6
            font.weight: Font.Light
            font.letterSpacing: root.font.pointSize * 0.07
            color: root.palette.text
            placeholderText: ""
            selectionColor: root.palette.highlight
            selectedTextColor: "#111111"
            selectByMouse: true
            hoverEnabled: true
            horizontalAlignment: TextInput.AlignHCenter
            renderType: Text.QtRendering
            Accessible.name: config.TranslatePlaceholderUsername || textConstants.userName
            onFocusChanged: {
                if (focus)
                    selectAll()
            }
            background: Item {
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width * (username.activeFocus ? 0.55 : username.hovered ? 0.35 : 0.16)
                    height: 1
                    color: username.activeFocus ? root.palette.highlight : "#38ffffff"
                    anchors.horizontalCenter: parent.horizontalCenter
                    Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 220 } }
                }
            }
            onTextEdited: userProfile.loginUserName = text
            onAccepted: password.forceActiveFocus()
            KeyNavigation.down: password
            Keys.onUpPressed: userMenu.open()
            Keys.onTabPressed: password.forceActiveFocus()
        }

        Item {
            anchors.top: username.bottom
            anchors.topMargin: root.font.pointSize * 0.25
            width: parent.width
            height: root.font.pointSize * 1.5

            Text {
                anchors.centerIn: parent
                width: parent.width * 0.92
                text: (config.TranslateChangeUser || "Сменить пользователя") + "   ▾"
                color: root.palette.text
                opacity: 0.45
                font.pointSize: root.font.pointSize * 0.7
                font.letterSpacing: root.font.pointSize * 0.03
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: userMenu.open()
            }
        }

        Popup {
            id: userMenu
            parent: userProfile
            x: (userProfile.width - width) / 2
            y: userProfile.height + 2
            width: userProfile.width * 0.86
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
                id: userMenuList
                implicitHeight: Math.min(contentHeight, root.font.pointSize * 15)
                model: userModel
                currentIndex: userProfile.userIndex
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollIndicator.vertical: ScrollIndicator { }

                delegate: ItemDelegate {
                    width: ListView.view.width
                    height: root.font.pointSize * 3.4
                    hoverEnabled: true
                    highlighted: ListView.isCurrentItem
                    Accessible.name: model.realName || model.name

                    contentItem: Item {
                        UserAvatar {
                            id: menuAvatar
                            anchors.left: parent.left
                            anchors.leftMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            width: root.font.pointSize * 2.2
                            height: width
                            source: model.name ? "file:///var/lib/AccountsService/icons/" + encodeURIComponent(model.name) : ""
                            name: model.name
                        }

                        Column {
                            anchors.left: menuAvatar.right
                            anchors.leftMargin: root.font.pointSize * 0.7
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 0

                            Text {
                                width: parent.width
                                text: model.realName || model.name
                                color: root.palette.text
                                font.pointSize: root.font.pointSize * 0.84
                                font.letterSpacing: root.font.pointSize * 0.03
                                elide: Text.ElideRight
                            }
                            Text {
                                width: parent.width
                                text: model.name
                                color: root.palette.text
                                opacity: 0.45
                                font.pointSize: root.font.pointSize * 0.68
                                elide: Text.ElideRight
                            }
                        }
                    }

                    background: Rectangle {
                        radius: config.RoundCorners || 0
                        color: parent.hovered || parent.highlighted ? "#242424" : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    onClicked: userProfile.chooseUser(index)
                }

                Keys.onReturnPressed: userProfile.chooseUser(currentIndex)
                Keys.onEnterPressed: userProfile.chooseUser(currentIndex)
                Keys.onEscapePressed: userMenu.close()
            }

            onOpened: {
                userMenuList.currentIndex = userProfile.userIndex
                userMenuList.forceActiveFocus()
            }
            onClosed: password.forceActiveFocus()
        }
    }

    Item {
        id: passwordField
        height: root.font.pointSize * 4.0
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter
        transform: Translate { id: passwordShake }

        SequentialAnimation {
            id: passwordShakeAnim

            NumberAnimation { target: passwordShake; property: "x"; from: 0; to: -6; duration: 60; easing.type: Easing.OutQuad }
            NumberAnimation { target: passwordShake; property: "x"; from: -6; to: 6; duration: 80; easing.type: Easing.InOutQuad }
            NumberAnimation { target: passwordShake; property: "x"; from: 6; to: -4; duration: 70; easing.type: Easing.InOutQuad }
            NumberAnimation { target: passwordShake; property: "x"; from: -4; to: 0; duration: 90; easing.type: Easing.OutQuad }
        }

        Text {
            anchors.fill: password
            text: config.TranslatePlaceholderPassword || textConstants.password
            visible: password.text.length === 0
            color: "#8a8a8a"
            opacity: 0.8
            font: password.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            renderType: Text.QtRendering
        }

        TextField {
            id: password
            anchors.centerIn: parent
            height: root.font.pointSize * 3
            width: parent.width
            padding: 0
            topPadding: 0
            bottomPadding: 0
            font.pointSize: root.font.pointSize * 1.0
            font.letterSpacing: root.font.pointSize * 0.04
            color: root.palette.text
            placeholderText: ""
            selectionColor: root.palette.highlight
            selectedTextColor: "#111111"
            focus: config.ForcePasswordFocus == "true" ? true : false
            selectByMouse: true
            hoverEnabled: true
            echoMode: revealSecret.checked ? TextInput.Normal : TextInput.Password
            horizontalAlignment: TextInput.AlignHCenter
            passwordCharacter: "•"
            passwordMaskDelay: config.ForceHideCompletePassword == "true" ? undefined : 1000
            renderType: Text.QtRendering
            Accessible.name: config.TranslatePlaceholderPassword || textConstants.password
            background: Item {
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width * (password.activeFocus ? 0.55 : password.hovered ? 0.35 : 0.16)
                    height: 1
                    color: password.activeFocus ? root.palette.highlight : "#38ffffff"
                    anchors.horizontalCenter: parent.horizontalCenter
                    Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 220 } }
                }
            }
            onAccepted: inputContainer.attemptLogin()
            KeyNavigation.down: revealSecret
            Keys.onTabPressed: revealSecret.forceActiveFocus()
        }

        Item {
            id: capsLockBadge
            visible: keyboard.capsLock || keyboard.numLock
            width: capsRow.implicitWidth + root.font.pointSize * 0.8
            height: root.font.pointSize * 1.55
            anchors.right: parent.right
            anchors.verticalCenter: password.verticalCenter
            Accessible.name: (keyboard.capsLock ? "Caps Lock" : "") +
                             (keyboard.capsLock && keyboard.numLock ? ", " : "") +
                             (keyboard.numLock ? "Num Lock" : "")

            Rectangle {
                anchors.fill: parent
                radius: 3
                color: "#10ffffff"
                border.width: 1
                border.color: "#26ffffff"
            }

            Row {
                id: capsRow
                anchors.centerIn: parent
                spacing: root.font.pointSize * 0.25

                Item {
                    width: root.font.pointSize * 0.9
                    height: root.font.pointSize * 1.2

                    Image {
                        anchors.centerIn: parent
                        width: root.font.pointSize * 0.85
                        height: width
                        source: Qt.resolvedUrl("../Assets/CapsLock.svg")
                        fillMode: Image.PreserveAspectFit
                        opacity: 0.65
                    }
                }

                Item {
                    width: capsText.implicitWidth
                    height: root.font.pointSize * 1.2

                    Text {
                        id: capsText
                        anchors.centerIn: parent
                        text: (keyboard.capsLock ? "CAPS" : "") +
                              (keyboard.capsLock && keyboard.numLock ? " · " : "") +
                              (keyboard.numLock ? "NUM" : "")
                        color: root.palette.text
                        opacity: 0.62
                        font.pointSize: root.font.pointSize * 0.58
                        font.letterSpacing: root.font.pointSize * 0.05
                    }
                }
            }
        }
    }

    Item {
        id: secretCheckBox
        height: root.font.pointSize * 2.8
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        CheckBox {
            id: revealSecret
            width: parent.width
            padding: 0
            hoverEnabled: true
            Accessible.name: config.TranslateShowPassword || "Показать пароль"

            indicator: Item {
                id: checkIndicator
                x: 4
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: root.font.pointSize * 1.15
                implicitHeight: implicitWidth

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.width: 1
                    border.color: revealSecret.checked || revealSecret.hovered || revealSecret.activeFocus ? root.palette.highlight : "#6a6a6a"
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }

                Image {
                    anchors.centerIn: parent
                    width: parent.width * 0.62
                    height: width
                    source: Qt.resolvedUrl("../Assets/Check.svg")
                    fillMode: Image.PreserveAspectFit
                    visible: revealSecret.checked
                    opacity: 0.92
                }
            }

            contentItem: Text {
                id: indicatorLabel
                anchors.verticalCenter: checkIndicator.verticalCenter
                anchors.left: checkIndicator.right
                anchors.leftMargin: root.font.pointSize * 0.55
                text: config.TranslateShowPassword || "Показать пароль"
                font.pointSize: root.font.pointSize * 0.76
                font.letterSpacing: root.font.pointSize * 0.03
                color: revealSecret.hovered || revealSecret.activeFocus ? root.palette.highlight : root.palette.text
                opacity: 0.7
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Keys.onReturnPressed: toggle()
            Keys.onEnterPressed: toggle()
            KeyNavigation.down: loginButton
            Keys.onTabPressed: loginButton.forceActiveFocus()
        }
    }

    Item {
        height: root.font.pointSize * 1.4
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter
        Label {
            id: errorMessage
            width: parent.width
            text: failed ? config.TranslateLoginFailedWarning || textConstants.loginFailed + "!" : null
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: root.font.pointSize * 0.78
            font.italic: true
            color: "#d6d6d6"
            opacity: 0
            states: [
                State {
                    name: "fail"
                    when: failed
                    PropertyChanges {
                        target: errorMessage
                        opacity: 1
                    }
                }
            ]
            transitions: [
                Transition {
                    PropertyAnimation {
                        properties: "opacity"
                        duration: 100
                    }
                }
            ]
        }
    }

    Item {
        id: login
        height: root.font.pointSize * 3.1
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        Button {
            id: loginButton
            anchors.horizontalCenter: parent.horizontalCenter
            text: config.TranslateLogin || textConstants.login
            height: root.font.pointSize * 3
            implicitWidth: parent.width
            enabled: (config.AllowEmptyPassword == "true" || username.text != "" && password.text != "") && !inputContainer.loginPending
            hoverEnabled: true
            Accessible.name: text

            contentItem: Text {
                text: parent.text
                color: config.OverrideLoginButtonTextColor !== "" ? config.OverrideLoginButtonTextColor : loginButton.enabled ? "#101010" : root.palette.text
                font.pointSize: root.font.pointSize * 0.92
                font.weight: Font.DemiBold
                font.letterSpacing: root.font.pointSize * 0.2
                font.capitalization: Font.AllUppercase
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                opacity: loginButton.enabled ? 1 : 0.35
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            background: Rectangle {
                id: buttonBackground
                color: !loginButton.enabled ? "transparent" :
                       loginButton.down ? "#c2c2c2" :
                       loginButton.hovered || loginButton.activeFocus ? "#ffffff" : "#e5e5e5"
                border.width: 1
                border.color: loginButton.activeFocus ? root.palette.text : loginButton.enabled ? "transparent" : "#494949"
                radius: config.RoundCorners || 0
                Behavior on color { ColorAnimation { duration: 220 } }
                Behavior on border.color { ColorAnimation { duration: 220 } }
            }

            onClicked: inputContainer.attemptLogin()
            Keys.onReturnPressed: clicked()
            Keys.onEnterPressed: clicked()
            KeyNavigation.down: sessionSelect.exposeSession
            Keys.onTabPressed: sessionSelect.exposeSession.forceActiveFocus()
        }
    }

    SessionButton {
        id: sessionSelect
        textConstantSession: textConstants.session
        loginButtonWidth: loginButton.background.width
    }

    Connections {
        target: sddm
        function onLoginSucceeded() {
            loginRecoverTimer.stop()
        }
        function onLoginFailed() {
            failed = true
            loginPending = false
            loginRecoverTimer.stop()
            if (root.animationsEnabled) {
                loginFadeBack.start()
                passwordShakeAnim.start()
            } else {
                formContainer.opacity = 1
            }
            if (resetError.running)
                resetError.restart()
            else
                resetError.start()
        }
    }

    Timer {
        id: loginTimer
        interval: 220
        repeat: false
        onTriggered: doLogin()
    }

    Timer {
        id: loginRecoverTimer
        interval: 2500
        repeat: false
        onTriggered: {
            if (loginPending) {
                loginPending = false
                if (root.animationsEnabled)
                    loginFadeBack.start()
                else
                    formContainer.opacity = 1
            }
        }
    }

    Timer {
        id: resetError
        interval: 2000
        onTriggered: failed = false
        running: false
    }
}
