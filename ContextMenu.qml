import QtQuick 2.9

Rectangle {
    z: parent.z + 10
    id: contextMenuItem
    signal menuSelected(int index) // index{1: Select All, 2: Remove Selected}
    property bool isOpen: false
    width: 150
    height: menuHolder.height + 20
    visible: isOpen
    focus: isOpen
    border { width: 1; color: "#BEC1C6" }

    Column {
        id: menuHolder
        spacing: 1
        width: parent.width
        height: children.height * children.length
        anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 3 }

        ContextItem {
            id: selectedAll
            button_text: "Select All"
            index: 1
            onButtonClicked: menuSelected(index);
        }

        ContextItem {
            id: removeSelected
            button_text: "Remove Selected"
            index: 2
            onButtonClicked: menuSelected(index);
        }
    }
}