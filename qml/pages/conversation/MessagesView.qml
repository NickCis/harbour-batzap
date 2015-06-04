import QtQuick 2.0
import Sailfish.Silica 1.0

SilicaListView {
    id: messagesView

    verticalLayoutDirection: ListView.BottomToTop
    // Arregla problema de foco al agregar un row
    currentIndex: -1
    quickScroll: false

    delegate: Item {
        id: wrapper

        height: messageDelegate.height
        width: parent.width

        ListView.onRemove: loader.itemanimateRemoval(wrapper)

        MessageDelegate {
            id: messageDelegate
            width: parent.width
            modelData: model
        }
    }

    function remove(contentItem){
        contentItem.remorseAction(qsTr("Delete message"), function(){
            console.log("Todo: delete")
        });
    }

    function copy(contentItem) {
        Clipboard.text = contentItem.modelData.message;
    }

    Component {
        id: messageContextMenu

        ContextMenu {
            id: menu

            onActiveChanged: {
                // TODO: chequear si puede reintentar
                retryItem.visible = false
            }

            width: parent ? parent.width : Screen.width
            MenuItem {
                id: retryItem
                text: qsTr("Retry")
                onClicked: console.log("TODO")
            }
            MenuItem {
                visible: menu.parent && menu.parent.hasText
                text: qsTr("Copy")
                onClicked: copy(menu.parent)
            }

            MenuItem {
                text: qsTr("Delete")
                onClicked: remove(menu.parent)
            }
        }
    }

    VerticalScrollDecorator {}
}
