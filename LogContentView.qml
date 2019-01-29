import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4


Item {
    id: root

    function positionViewAtRow(row) {
        tableView.positionViewAtRow(row);
        tableView.selection.clear();
        tableView.selection.select(row);
    }

    Item {
        id: contextMenu

        function show() {
            visible = true;
        }

        function hide() {
            visible = false;
        }

        function setPosition(x, y) {
            menu.x = x;
            menu.y = y;
        }

        anchors.fill: parent
        z: parent.z + 10
        visible: false

        Rectangle {
            z: parent.z + 1
            color: "darkgray"
            anchors.fill: parent
            opacity: 0.4
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                parent.visible = false;
            }
        }

        ContextMenu {
            id: menu

            isOpen: parent.visible

            onMenuSelected: {
                console.log(index)
            }
        }
    }

    TableView {
        id: tableView

        anchors.fill: parent

        model: LogQmlAdapter.info

        TableViewColumn {
            role: "timestamp"
            title: "Timestamp"
            width: 150
        }
        TableViewColumn {
            role: "thread_info"
            title: "Thread ID"
            width: 150
        }

        TableViewColumn {
            role: "severity"
            title: "Severity"
            width: 80
        }
        TableViewColumn {
            role: "message"
            title: "Message"
            width: root.width / 2
        }
    }
}
