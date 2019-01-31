import QtQuick 2.0
import QtQuick.Controls 2.2

Item {
    id: root

    property alias text: text.text
//    property alias buttonText: button.text
//    property alias buttonVisibility: button.visible

    Rectangle {
        anchors.fill: parent
        opacity: 0.3
        color: "darkgray"
    }

    Text {
        id: text

        anchors.centerIn: parent
        font.pointSize: 30

        text: "Drop your file here"
    }

//    Column {

//        Text {
//            id: text
////            anchors.centerIn: parent
//            anchors.horizontalCenter: parent.horizontalCenter
//            font.pointSize: 30

//            text: "Drop your file here"
//        }

//        Button {
//            id: button

//            anchors.horizontalCenter: parent.horizontalCenter
//            text: "OK"
//            visible: false

//            onClicked: {
//                root.visible = false;
//                visible = false;
//            }
//        }
//    }
}
