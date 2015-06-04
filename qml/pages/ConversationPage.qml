import QtQuick 2.0
import Sailfish.Silica 1.0

import "conversation"

import harbour.batzap.client 1.0

Page {
    id: conversationPage

    property int conversationId
    property string contactName: ""
    property bool editorFocus
    property bool hasDraftText: false

    function sendMessage(text){
        var id = BatZap.sendMessage(conversationPage.conversationId, text);
        if(!id)
            return;

        messages.model.insert(0, {
            id: id,
            message: text
        });
    }

    MessagesView {
        function reloadMessageList(){
            model.clear();
            for(
                var eles=BatZap.getConversationMessages(conversationPage.conversationId),
                    i=0,
                    e;
                (e=eles[i]);
            i++){
                model.append(e)
            }
        }

        Component.onCompleted: reloadMessageList()

        id: messages
        focus: true
        anchors.fill: parent
        model: ListModel {
            /*ListElement {
                from: "pepe"
                message: "1 er mensaje"
                time: 1431493328
            }
            ListElement {
                from: ""
                message: "te respondo"
                time: 1431493328
            }
            ListElement {
                from: "pepe"
                message: "ay que lindo"
                time: 1431493328
            }
            ListElement {
                from: ""
                message: "hola esto es un mensaje"
                time: 1431493328
            }
            ListElement {
                from: ""
                message: "hola esto es un mensaje"
                time: 1431493328
            }
            ListElement {
                from: "pepe"
                message: "mas cosas"
                time: 1431493328
            }
            ListElement {
                from: "pepe"
                message: "hola esto es un mensaje"
                time: 1431493328
            }
            ListElement {
                from: ""
                message: "hola esto es un mensaje"
                time: 1431493328
            }
            ListElement {
                from: "pepe"
                message: "ssssssssssssssssssssssss"
                time: 1431493328
            }
            ListElement {
                from: ""
                message: "hola esto es un mensaje"
                time: 1431493328
            }
            ListElement {
                from: ""
                message: "hola esto es un mensaje"
                time: 1431493328
            }
            ListElement {
                from: "pepe"
                message: "asddddddd aksjdkajskd aj sdk "
                time: 1431493328
            }
            ListElement {
                from: "pepe"
                message: "ante ultimo"
                time: 1431493328
            }
            ListElement {
                from: ""
                message: "Ultimo mensaje"
                time: 1431493328
            }*/
        }

        header: Item {
            width: messages.width
            height: textInput.height
        }

        Column {
            id: headerArea
            y: messages.headerItem.y
            parent: messages.contentItem
            width: parent.width

            ChatTextInput {
                id: textInput
                contactName: conversationPage.contactName
                width: parent.width

                editorFocus: conversationPage.editorFocus

                onSendMessage: conversationPage.sendMessage(text)
            }
        }

        Connections {
            target: BatZap
            onNewMessage:{
                if(message.idconversation != conversationPage.conversationId)
                    return;

                for(var i=0; i < messages.model.count ;i++){
                    var it = messages.model.get(i);
                    if(it.id == message.id ){
                        for(var key in message)
                            it[key] = message[key];
                        return;
                    }

                    if(it.time && it.time < message.time)
                        break;
                }

                messages.model.insert(0, message);
            }
        }
    }
}
