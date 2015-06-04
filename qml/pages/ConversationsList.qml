import QtQuick 2.0
import Sailfish.Silica 1.0

import "conversation"

import harbour.batzap.client 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    SilicaListView {
        id: view
        anchors.fill: parent
        model: ListModel {}
        header: Item { width: parent.width; height: Theme.paddingLarge }
        section.property: "weekDaySection"
        //section.property: "time"

        function reloadConversationList(){
            model.clear();
            for(var eles=BatZap.getLastConversations(), i=0, e; (e = eles[i]); i++){
                model.append(e);
            }
        }

        delegate: Item {
            id: wrapper
            property bool sectionBoundary: ListView.previusSection != ListView.section
            property Item section

            height: section === null ? content.height : content.height + section.height
            width: parent.width

            ListView.onRemove: content.animateRemoval(wrapper)

            onSectionBoundaryChanged: {
                if(sectionBoundary){
                    section = sectionHeader.createObject(wrapper)
                } else {
                    section.destroy()
                    section = null
                }
            }

            ConversationDelegate {
                id: content
                y: section ? section.height : 0
                onClicked: {
                    pageStack.push("ConversationPage.qml", {
                        conversationId: model.idconversation,
                        contactName: model.name
                    }, PageStackAction.Animated)
                }
            }
        }

        Component.onCompleted: reloadConversationList()

        Component {
            id: sectionHeader
            Label {
                property string section: parent.ListView.section
                width: parent.width - (2 * Theme.horizontalPageMargin)
                height: text.length ? implicitHeight : 0
                x: Theme.horizontalPageMargin

                horizontalAlignment: Text.AlignRight
                color: Theme.highlightColor

                text: Format.formatDate(section, Formatter.TimepointSectionRelative)
            }

        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Quit")
                onClicked: Qt.quit()
            }

            MenuItem {
                text: qsTr("Logout")
                onClicked: console.log("todo")
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
            MenuItem {
                text: qsTr("Broadcast")
                onClicked: console.log("todo")
            }
        }

        ViewPlaceholder {
            text: qsTr("No messages")
            enabled: view.count === 0
        }

        VerticalScrollDecorator {}

        Connections {
            target: BatZap
            onNewMessage:{
                for(var i=0; i < view.model.count ;i++){
                    var it = view.model.get(i);
                    if(it.idconversation == message.idconversation ){
                        it.message = message.message;
                        it.time = message.time;
                        view.model.move(i, 0, 1);
                        return;
                    }
                }

                view.model.insert(0, message);
            }
        }
    }
}
