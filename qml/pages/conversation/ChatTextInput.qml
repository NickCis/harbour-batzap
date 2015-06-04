import QtQuick 2.0
import Sailfish.Silica 1.0

import harbour.batzap.client 1.0

InverseMouseArea {
    id: chatInputArea

    height: timestamp.y + timestamp.height + Theme.paddingMedium

    property string contactName: ""
    property alias text: textField.text
    property alias cursorPosition: textField.cursorPosition
    property alias editorFocus: textField.focus
    property bool enabled: true

    signal sendMessage(string text)

    function send(){
        Qt.inputMethod.commit();
        if(text.length < 1)
            return
        sendMessage(text)
        text = ""
        // TODO: draft!

        if(textField.focus){
            textField.focus = false;
            textField.focus = true;
        }
    }

    function forceActiveFocus(){
        textField.foceActiveFocus()
    }

    function reset(){
        Qt.inputMethod.comit()
        text = ""
    }

    TextArea {
        id: textField
        anchors {
            left: parent.left
            right: sendButtonArea.left
            top: parent.top
            topMargin: Theme.paddingMedium
        }

        focusOutBehavior: FocusBehavior.KeepFocus
        textRightMargin: 0
        font.pixelSize: Theme.fontSizeSmall

        property bool empty: text.length === 0 && !inputMethodComposing

        // TODO: hacerlo lindo
        placeholderText: contactName.length ? (qsTr("Hi, ") + contactName) : qsTr("Hi!")
    }

    onClickedOutside: textField.focus = false

    MouseArea {
        id: sendButtonArea
        anchors {
            fill: sendButtonText
            margins: -Theme.paddingLarge
        }

        enabled: !textField.empty && chatInputArea.enabled
        onClicked: chatInputArea.send()
    }

    Label {
        id: sendButtonText
        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: textField.top
            verticalCenterOffset: textField.textVerticalCenterOffset + (textField._editor.height - height)
        }

        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Qt.AlignRight
        color: !sendButtonArea.enabled ? Theme.secondaryColor
                                       : (sendButtonArea.pressed ? Theme.highlightColor
                                                                 : Theme.primaryColor)
        text: qsTr("Send")
    }

    Label {
        id: timestamp
        anchors {
            top: textField.bottom
            topMargin: -textField._labelItem.height - 3
            left: textField.left
            leftMargin: Theme.horizontalPageMargin
            right: textField.right
        }

        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeTiny

        function  updateTimestamp(){
            var date = new Date();
            text = Format.formatDate(date, Formatter.TimepointRelative)
            update.interval = (60 - date.getSeconds() +1) * 1000
        }

        Timer {
            id: updater
            repeat: true
            triggeredOnStart: true
            running: Qt.application.active && timestamp.visible
            onTriggered: timestamp.updateTimestamp()
        }
    }

    Label {
        id: messageType
        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            top: timestamp.top
        }

        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeTiny
        horizontalAlignment: Qt.AlignRight
        text: "BatZap"

        ContactPresenceIndicator {
            id: presence
            anchors {
                right: parent.right
                rightMargin: 2
                bottom: parent.top
            }

            presenceState: 1
        }
    }

}
