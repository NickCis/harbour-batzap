import QtQuick 2.0
import Sailfish.Silica 1.0
import "js/loader.js" as Loader

import harbour.batzap.client 1.0

Dialog {
    id: dialog
    property string responseText: ""

    allowedOrientations: Orientation.All
    acceptDestination: nextPage
    acceptDestinationAction: PageStackAction.Push
    canAccept: !username.errorHighlight && !password.errorHighlight

    Column {
        id: column

        width: parent.width
        spacing: Theme.paddingLarge

        DialogHeader {
            dialog: parent.parent
            acceptText: qsTr("Signup")
            title: qsTr("Fill the form")
        }

        TextField {
            id: username
            width: parent.width
            label: qsTr("Username")
            placeholderText: label
            focus: true
            horizontalAlignment: TextInput.AlignLeft
            //validator: RegExpValidator { regExp: /[0-9a-zA-Z_-.,]/ }
            EnterKey.onClicked: password.focus = true
        }

        TextField {
            id: password
            width: parent.width
            inputMethodHints: Qt.ImhNoPredictiveText
            echoMode: TextInput.Password
            label: qsTr("Enter password")
            placeholderText: label
            horizontalAlignment: TextInput.AlignLeft
            validator: RegExpValidator { regExp: /^.{6,}$/ }
            EnterKey.onClicked: dialog.accept()
        }
    }
    onAccepted:{
        BatZap.signup(username.text, password.text)
    }

    Component {
        id: nextPage

        Page {
            backNavigation: !busyIndicator.visible

            Column {
                anchors { left: parent.left; right: parent.right }
                spacing: Theme.paddingLarge

                PageHeader { title: "Creating Account" }

                TextArea {
                    id: response
                    width: parent.width
                    readOnly: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: dialog.responseText
                    visible: dialog.responseText.length > 0
                }
            }

            BusyIndicator {
                id: busyIndicator
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                visible: !response.visible
                running: true
                size: BusyIndicatorSize.Large
            }

        }
    }

    Connections {
        target: BatZap
        onSignupResponse: {
            if(error)
                dialog.responseText = desc
            else{
                Loader.doOnPageStackNotBusy(function(){
                    pageStack.pop(pageStack.previousPage(dialog), PageStackAction.Animated);
                });
            }
        }
    }
}



