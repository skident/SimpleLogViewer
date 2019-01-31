import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3

import "."

ApplicationWindow {
    id: root

    visible: true
    width: 640
    height: 480
    title: qsTr("Simple log viewer")

    readonly property var foundIds: LogQmlAdapter.foundIds

    onFoundIdsChanged: {
        console.log("found list changed")
        logContentView.clearHighlights();
        for (var i = 0; i < foundIds.length; i++) {
            logContentView.highlightRow(foundIds[i]);
        }
    }

    function positionViewAtRow(idx) {
        logContentView.positionViewAtRow(idx);
    }

    function percents(totalWidth, percents) {
        return totalWidth * (percents / 100);
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

    DropAreaTile {
        id: dropAreaTile
        anchors.fill: parent

        z: parent.z + 100

        visible: false
    }

    DropArea {
        id: drop
        anchors.fill: parent

        enabled: true

        onEntered: {
            dropAreaTile.visible = true;
            // Make some validations of dragged files
            if (drag.urls.length > 1) {
                console.warn("Only one file will be loaded");
            }
        }

        onExited: {
            dropAreaTile.visible = false;
            console.log("exited")
        }

        onDropped: {
            console.log("dropped")
            dropAreaTile.text = "Processing the file"

            for(var i = 0; i < drop.urls.length; i++) {
                console.log(drop.urls[i]);
            }

            // TODO: ask to save previous log file
            MainController.closeCurrent();
            var res = MainController.openFile(drop.urls[0]);
//            if (res) {
//                dropAreaTile.text = "Loaded successfully!"
//            } else {
//                dropAreaTile.text = "Something went wrong!"
////                dropAreaTile.buttonVisibility = true;
//            }
            dropAreaTile.visible = false;
            dropAreaTile.text = "Drop your file"
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

                Keys.onReturnPressed: {
                    var idx = LogQmlAdapter.findAllElements(search.text);
                    if (idx >= 0) {
                        root.positionViewAtRow(idx);
                    }
                    search.text = ""
                }
            }

            Button {
                text: "find"
                onClicked: {
                    var idx = LogQmlAdapter.findAllElements(search.text);
                    if (idx >= 0) {
                        root.positionViewAtRow(idx);
                    }
                }
            }

            Button {
                text: "clear"
                onClicked: {
                    LogQmlAdapter.resetSearch();
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
            width: root.percents(parent.width, 80)
        }

        FilteringPanel {
            id: filteringPanel

            Layout.minimumWidth: minimalWidth

            width: root.percents(parent.width, 20)
            color: "#e6e2d3"
        }
    }

    PopupWindow {
        id: popup
    }
}
