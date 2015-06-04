import QtQuick 2.0
import Sailfish.Silica 1.0

import "../conversation"
import "../js/utils.js" as Utils

ListItem {
    id: delegate
    contentHeight: textColumn.height + Theme.paddingMedium + textColumn.y
    menu: contextMenuComponent

    Column {
        id: textColumn
        anchors {
            top: parent.top
            topMargin: Theme.paddingSmall
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: parent.right
            rightMargin: Theme.horizontalPagemargin
        }

        Row {
            width: parent.width

            /* TODO: group chats
                        Image {
                            id: groupIcon
                            source: false ? ("image://theme/icon-s-group-chat?" + (delegate.highlighted ? Theme.highlightColor : Theme.primaryColor)) : ""
                            anchors.verticalCenter: name.verticalCenter
                        }*/

            /* TODO: que guarde lo que escribiste si saliste de la conversacion
                        Image {
                            id: draftIcon
                            source: false ? ("image://theme/icon-s-edit?" + (delegate.highlighted ? Theme.highlightColor : Theme.primaryColor)) : ""
                            anchors.verticalCenter: name.verticalCenter
                        }*/

            Label {
                id: name
                width: parent.width - x
                truncationMode: TruncationMode.Fade
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                text: Utils.toCapitalLetter(model.name)
            }
        }

        Label {
            id: lastMessage
            anchors.left: parent.left
            anchors.right: parent.right

            text: model.message
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeExtraSmall
            color: delegate.highlighted || /* unread messages*/ false ? Theme.highlightColor : Theme.primaryColor
            wrapMode: Text.Wrap
            maximumLineCount: 3
        }

        Label {
            id: date
            color: delegate.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            text: Format.formatDate(Utils.epochToDate(model.time), Formatter.TimepointRelative);

            ContactPresenceIndicator {
                id: presence
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.right
                    leftMargin: Theme.paddingMedium
                }
                presenceState: 1
            }
        }
    }

    function remove() {
        remorseAction(qsTr("Remove conversation"), function() { console.log("todo remove conversation") });
    }

    Component {
        id: contextMenuComponent
        ContextMenu {
            id: menu
            MenuItem {
                text: qsTr("Delete conversation")
                onClicked: remove()
            }
        }
    }
}
