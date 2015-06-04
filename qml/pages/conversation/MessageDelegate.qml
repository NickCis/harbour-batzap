import QtQuick 2.0
import Sailfish.Silica 1.0

import Sailfish.TextLinking 1.0

ListItem {
    id: message
    contentHeight: Math.max(timestamp.y + timestamp.height, retryIcon.height) + Theme.paddingMedium
    menu: messageContextMenu

    property QtObject modelData
    property bool inbound: modelData ? (modelData.from ? true : false) : false
    property bool hasAttachments: modelData ? ( modelData.file ? true : false ) : false
    property bool hasText
    property bool canRetry

    Image {
        id: retryIcon
        anchors {
            left: inbound ? undefined : parent.left
            right: inbound ? parent.right : undefined
            bottom: parent.bottom
        }
    }

    Column {
        id: attachments
        height: Math.max(implicitHeight, attachmentOverlay.height)
        width: Math.max(implicitWidth, attachmentOverlay.width)

        anchors {
            left: inbound ? undefined : parent.left
            right: inbound ? parent.right : undefined
            bottom: messageText.bottom
            bottomMargin: messageText.y
        }

        Repeater {
            id: attachmentLoader
            // TODO: set model
            //model:

            //AttachmentDelegate {
            //}
        }

    }

    Item {
       id: attachmentOverlay
       width: height
       height: (busyLoader.active || attachmentRetryIcon.status === Image.Ready) ? Theme.itemSizeLarge : 0
       anchors {
           left: attachments.left
           bottom: attachments.bottom
       }

       Rectangle {
           anchors.fill: parent
           color: Theme.highlightColor
           opacity: 0.1
       }

       Loader {
           id: busyLoader
           active: false
           //active: modelData.status === CommHistory.DownloadingStatus || modelData.status === CommHistory.WaitingStatus
           anchors.centerIn: parent
           sourceComponent: BusyIndicator {
               running: true
           }
       }

       Image {
           id: attachmentRetryIcon
           anchors.centerIn: parent
       }
    }

    LinkedText {
        id: messageText
        anchors {
            left: inbound ? parent.left : attachments.right
            right: inbound ? attachments.left : parent.right
            leftMargin: inbound ? sidePadding : (attachments.height ? Theme.paddingMedium : (retryIcon.width ? Theme.paddingMedium : Theme.horizontalPageMargin))
            rightMargin: !inbound ? sidePadding : (attachments.height ? Theme.paddingMedium : (retryIcon.width ? Theme.paddingMedium : Theme.horizontalPageMargin))
        }

        property int sidePadding: Theme.itemSizeSmall + Theme.horizontalPageMargin
        y: Theme.paddingMedium / 2
        height: Math.max(implicitHeight, attachments.height)
        wrapMode: Text.Wrap

        plainText: {
            if(!modelData.message){
                hasText = false;
                return ""
            }
            // TODO: attachments
            hasText = true
            return modelData.message
        }

        color: (message.highlighted || !inbound) ? Theme.highlightColor : Theme.primaryColor
        font.pixelSize: inbound ? Theme.fontSizeMedium : Theme.fontSizeSmall
        horizontalAlignment: inbound ? Qt.AlignRight : Qt.AlignLeft
        verticalAlignment: Qt.AlignBottom

    }

    Label {
        id: timestamp
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            top: messageText.bottom
            topMargin: Theme.paddingSmall
        }

        color: messageText.color
        opacity: 0.6
        font.pixelSize: Theme.fontSizeExtraSmall
        horizontalAlignment: messageText.horizontalAlignment

        text: {
            // TODO: Poner tiempo y estado de enviado, recibido, leido, etc
            if(!modelData.time)
                return qsTr("sending");

            var date = new Date(0);
            date.setUTCSeconds(modelData.time);
            var re = Format.formatDate(date, Formatter.Timepoint);
            if(inbound)
                return re;

            re += " \u2713";
            if(modelData.arrived)
                re += " \u2713";
            if(modelData.read)
                re += " \u2713";

            return re;
        }

    }

    onClicked: {
        if(canRetry){
            console.log("reenviar mensaje!")
        }/* si tiene attachment hacer algo tmb*/
    }

    /*states: [
        State {
            name: "outboundErrorNoAttachment"
            when: !inbound && modelData.status >= CommHistory.TemporarilyFailedStatus && attachments.height == 0
            extend: "outboundError"

            PropertyChanges {
                target: retryIcon
                source: "image://theme/icon-m-refresh?" + (message.highlighted ? Theme.highlightColor : Theme.primaryColor)
            }

            AnchorChanges {
                target: timestamp
                anchors.left: inbound ? undefined : retryIcon.right
                anchors.right: inbound ? retryIcon.left : undefined
            }

            PropertyChanges {
                target: timestamp
                anchors.leftMargin: Theme.paddingMedium
                anchors.rightMargin: Theme.paddingMedium
            }
        },
        State {
            name: "outboundError"
            when: !inbound && modelData.status >= CommHistory.TemporarilyFailedStatus
            extend: "error"

            PropertyChanges {
                target: timestamp
                //% "Problem with sending message"
                text: qsTrId("messages-send_status_failed")
            }
        },
        State {
            name: "manualReceive"
            when: inbound && modelData.status === CommHistory.ManualNotificationStatus
            extend: "inboundError"

            PropertyChanges {
                target: timestamp
                //% "Tap to download multimedia message"
                text: qsTrId("messages-mms_manual_download_prompt")
            }
        },
        State {
            name: "inboundError"
            when: inbound && modelData.status >= CommHistory.TemporarilyFailedStatus
            extend: "error"

            PropertyChanges {
                target: attachmentRetryIcon
                source: "image://theme/icon-m-refresh?" + (message.highlighted ? Theme.highlightColor : Theme.primaryColor)
            }

            PropertyChanges {
                target: timestamp
                //% "Problem with downloading message"
                text: qsTrId("messages-receive_status_failed")
            }

        },
        State {
            name: "error"

            PropertyChanges {
                target: message
                canRetry: true
            }

            PropertyChanges {
                target: messageText
                opacity: 1
            }

            PropertyChanges {
                target: timestamp
                opacity: 1
                color: message.highlighted ? messageText.color : Theme.primaryColor
            }
        }
    ]*/
}
