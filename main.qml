import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3

//import Qt.labs.platform 1.0

import "."

ApplicationWindow {
    id: root

    visible: true
    width: 640
    height: 480
    title: qsTr("Simple log viewer")

    function positionViewAtRow(idx) {
        logContentView.positionViewAtRow(idx);
    }

    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        folder: shortcuts.home
        onAccepted: {
            console.log("You chose: " + fileDialog.fileUrl)
            MainController.openFile(fileDialog.fileUrl);
        }
    }

    SaveFileDialog {
        id: saveFileDialog

        onAccepted: {
            //            console.log("You chose: " + saveFileDialog.currentFile)
            MainController.saveToFile(saveFileDialog.currentFile);
        }
    }

    menuBar: MenuBar {
        Menu {
            title: "File"
            MenuItem {
                text: "Open log"
                onTriggered: {
                    fileDialog.visible = true;
                }
            }

            MenuSeparator {}

            MenuItem {
                text: "Save log"

                onTriggered: {
                    saveFileDialog.open()
                }
            }

            MenuSeparator {}

            MenuItem {
                text: "Close log"

                onTriggered: {
                    MainController.closeCurrent();
                }
            }
        }

        Menu {
            title: "Edit"
            MenuItem { text: "Cut" }
            MenuItem { text: "Copy" }
            MenuItem { text: "Paste" }
        }
    }



    ///////////

    DropArea {
        id: drop
        anchors.fill: parent

        enabled: true

        onEntered: {
            // Make some validations of dragged files
            if (drag.urls.length > 1) {
                console.warn("Only one file will be loaded");
            }
        }

        onExited: {
            console.log("exited")
        }

        onDropped: {
            console.log("dropped")

            for(var i = 0; i < drop.urls.length; i++) {
                console.log(drop.urls[i]);
            }

            // TODO: ask to save previous log file
            MainController.closeCurrent();
            MainController.openFile(drop.urls[0]);
        }
    }

    ///////////



    Rectangle {
        id: searchPanel

        anchors.top: parent.top
        width: parent.width
        height: childrenRect.height

        Row {
            TextField {
                id: search
            }

            Button {
                text: "find"
                onClicked: {
                    var idx = LogQmlAdapter.findElement(search.text);
                    if (idx >= 0) {
                        root.positionViewAtRow(idx);
                    }
                }
            }
        }
    }

    SplitView {
        anchors {
            top: searchPanel.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        orientation: Qt.Horizontal
        resizing: true

        LogContentView {
            id: logContentView
            width: parent.width / 3 * 2
        }


        FilteringPanel {
            id: filteringPanel

            Layout.minimumWidth: minimalWidth

            width: parent.width / 3
            color: "lightgreen"
        }
    }

    PopupWindow {
        id: popup
    }
}
