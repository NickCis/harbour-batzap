import QtQuick 2.0
import Sailfish.Silica 1.0

import harbour.batzap.client 1.0


Page {

    id: page

    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column

            width: parent.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Settings")
            }

            TextField {
                width: parent.width
                label: qsTr("Host")
                placeholderText: label
                text: BatZap.getHost()
                focus: true
                horizontalAlignment: TextInput.AlignLeft
                onTextChanged: BatZap.host = text
                EnterKey.onClicked: BatZap.host = text
            }

            TextField {
                width: parent.width
                label: qsTr("Port")
                placeholderText: label
                text: BatZap.getPort()
                horizontalAlignment: TextInput.AlignLeft
                EnterKey.onClicked: BatZap.port = parseInt(text, 10)
                onTextChanged: BatZap.port = parseInt(text, 10)
                inputMethodHints: Qt.ImhDigitsOnly
            }
        }
    }
}
