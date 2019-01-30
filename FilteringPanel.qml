import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Rectangle {
    id: root

    readonly property int minimalWidth: filterColumn.childrenRect.width

    function applyFilter(fieldName, comparisonType, value) {
        LogQmlAdapter.applyFilter(fieldName, comparisonType, value);
    }

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

                placeholderText: "enter your text"

                Keys.onReturnPressed: {
                    root.applyFilter(field.currentText, comparison.currentText, value.text);
                    value.text = ""
                }
            }


            Button {
                id: addFilterButton
                text: "ADD"
                onClicked: {
                    root.applyFilter(field.currentText, comparison.currentText, value.text);
                    value.text = ""
//                    LogQmlAdapter.applyFilter(field.currentText, comparison.currentText, value.text);
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
