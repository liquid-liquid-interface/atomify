import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import Atomify 1.0
import SimVis 1.0
import Qt.labs.settings 1.0
import QtCharts  2.0
import "mobile"
import "mobile/style"
import "desktop"

ApplicationWindow {
    id: applicationRoot

    title: qsTr("Atomify")
    width: 300
    height: 480
    visible: true

    property string mode: {
        if(["android", "ios", "winphone"].indexOf(Qt.platform.os) > -1) {
            return "mobile"
        }
        return "desktop"
    }

    Settings {
        id: settings
//        property alias mode: applicationRoot.mode
        property alias width: applicationRoot.width
        property alias height: applicationRoot.height
    }

    function resetStyle() {
        Style.reset(width, height, Screen)
    }

    onWidthChanged: {
        resetStyle()
    }

    onHeightChanged: {
        resetStyle()
    }

    Component.onCompleted: {
        resetStyle()
    }

    MainDesktop {
        visible: mode === "desktop"
        anchors.fill: parent
    }

    MainMobile {
        visible: mode === "mobile"
        anchors.fill: parent
    }

    Shortcut {
        sequence: StandardKey.AddTab
        context: Qt.ApplicationShortcut
        onActivated: {
            if(mode === "desktop") {
                mode = "mobile"
            } else {
                mode = "desktop"
            }
        }
    }
    Shortcut {
        sequence: StandardKey.FullScreen
        context: Qt.ApplicationShortcut
        onActivated: {
            if(visibility === Window.FullScreen) {
                visibility = Window.AutomaticVisibility
            } else {
                visibility = Window.FullScreen
            }
        }
    }
}
