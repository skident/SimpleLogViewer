import QtQuick 2.0

Item {
    anchors.fill: parent

    visible: false

    Rectangle {
        anchors.fill: parent
        opacity: 0.3
        color: "darkgray"
    }

    Rectangle {
        id: popup

        width: 300
        height: width

        z: parent.z + 5

        Rectangle {
            anchors.fill: parent
        }

        Image {
            z: parent.z + 1

            anchors.right: parent.right
            anchors.top: parent.top

            anchors.margins: 10

            width: 20
            height: 20

            source: "resources/close.png"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.visible = false;
                }
            }
        }
    }
}
