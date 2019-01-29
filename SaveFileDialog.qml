import QtQuick 2.0
import Qt.labs.platform 1.0

FileDialog {
    id: root

    fileMode: FileDialog.SaveFile
    folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)

//    onAccepted: {
//        root.
//    }
}
