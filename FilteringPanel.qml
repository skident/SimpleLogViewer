import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Rectangle {
    readonly property int minimalWidth: filterColumn.childrenRect.width

    Column {
        anchors.fill: parent

        Item {
            width: 1
            height: 20
        }


        Column {
            id: filterColumn
            spacing: 4

            anchors.horizontalCenter: parent.horizontalCenter

            ComboBox {
                id: field
                width: 150
                model: [ "thread", "severity", "msg" ]
            }

            ComboBox {
                id: comparison
                width: 150
                model: [ "==", "!=" ] // TODO: <, >, <=, >=
            }

            TextField {
                id: value

//                style: TextFieldStyle {
//                    textColor: "black"
//                    background: Rectangle {
//                        radius: 2
//                        implicitWidth: 150
//                        implicitHeight: 24
//                        border.color: "#333"
//                        border.width: 1
//                    }
//                }
            }


            Button {
                text: "ADD"
                onClicked: {
                    LogQmlAdapter.applyFilter(field.currentText, comparison.currentText, value.text);
                }
            }
        }

        ListView {
            width: parent.width
            height: childrenRect.height
            spacing: 5
            anchors.margins: 5

            model: LogQmlAdapter.filters
            delegate: Rectangle {
                radius: 5
                width: childrenRect.width
                height: childrenRect.height
                color: "lightgray"

                Row {
                    spacing: 5
                    Text {
                        text: modelData
                    }
                    Image {
                        source: "resources/close.png"

                        width: 15
                        height: width
                        smooth: true

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                LogQmlAdapter.removeFilter(modelData);
                            }
                        }
                    }
                }
            }
        }
    }
}
