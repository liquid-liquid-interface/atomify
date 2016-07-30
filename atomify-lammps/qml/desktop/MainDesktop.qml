import QtQuick 2.7
import QtQuick.Controls 1.5
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import Atomify 1.0
import SimVis 1.0
import Qt.labs.settings 1.0

import "../visualization"

Item {
    id: desktopRoot

    property AtomifySimulator simulator: visualizer.simulator
    property alias visualizer: visualizer
    property bool focusMode: false

    Component.onCompleted: {
        editorTab.lammpsEditor.runScript()
    }

    Row {
        anchors.fill: parent

        SplitView {
            height: parent.height
            width: parent.width-simulationSummary.width
            Layout.alignment: Qt.AlignTop
            orientation: Qt.Horizontal

            EditorTab {
                id: editorTab
                Layout.fillHeight: true
                width: 500

                simulator: desktopRoot.simulator
                visualizer: desktopRoot.visualizer
                Component.onCompleted: {
                    simulator.errorInLammpsScript.connect(editorTab.reportError)
                }
            }

            AtomifyVisualizer {
                id: visualizer
                Layout.alignment: Qt.AlignLeft
                Layout.fillHeight: true
                Layout.minimumWidth: 1
                focus: true
                ambientOcclusion.radius: radiusSlider.value
                ambientOcclusion.samples: samplesSlider.value
                ambientOcclusion.noiseScale: noiseScaleSlider.value
                ambientOcclusion.mode: ssaoMode.currentText
                sphereScale: sphereScalingSlider.value
                bondRadius: bondRadiusSlider.value
            }

        }

        SimulationSummary {
            id: simulationSummary
            width: 300
            height: parent.height
            system: simulator.system ? simulator.system : null

            Column {
                y: parent.height - 300
                width: parent.width
                Row {
                    Label {
                        width: 150
                        text: "SSAO Radius ("+radiusSlider.value.toFixed(1)+"): "
                    }

                    Slider {
                        id: radiusSlider
                        width: 150
                        minimumValue: 0.0
                        value: 8.0
                        maximumValue: 50.0
                    }
                }

                Row {
                    Label {
                        width: 150
                        text: "SSAO Noise ("+noiseScaleSlider.value.toFixed(1)+"): "
                    }

                    Slider {
                        id: noiseScaleSlider
                        width: 150
                        minimumValue: 0.0
                        value: 1.0
                        maximumValue: 10.0
                    }
                }

                Row {
                    Label {
                        width: 150
                        text: "SSAO samples ("+samplesSlider.value+"): "
                    }
                    Slider {
                        id: samplesSlider
                        width: 150
                        minimumValue: 1
                        value: 32
                        stepSize: 1
                        maximumValue: 64
                    }
                }

                Row {
                    Label {
                        width: 150
                        text: "Sphere scaling ("+sphereScalingSlider.value.toFixed(2)+"): "
                    }
                    Slider {
                        id: sphereScalingSlider
                        width: 150
                        minimumValue: 0.1
                        maximumValue: 1.0
                        value: 0.23
                        stepSize: 0.01
                    }
                }

                Row {
                    Label {
                        width: 150
                        text: "Bond radius ("+bondRadiusSlider.value.toFixed(2)+"): "
                    }
                    Slider {
                        id: bondRadiusSlider
                        width: 150
                        minimumValue: 0.1
                        maximumValue: 1.0
                        value: 0.3
                        stepSize: 0.01
                    }
                }

                ComboBox {
                    id: ssaoMode
                    model: ["hemisphere", "sphere"]
                    currentIndex: 0
                }

                ComboBox {
                    model: ["blurMultiply", "ssaoMultiply", "blur", "ssao", "position", "color", "normal"]
                    currentIndex: 0
                    onCurrentTextChanged: {
                        visualizer.finalShaderBuilder.selectOutput(currentText)
                    }
                }
            }
        }
    }

    function toggleFocusMode() {
        if(focusMode) {
            simulationSummary.width = 300
            simulationSummary.visible = true
            editorTab.visible = true
            focusMode = false
            tabDisable.hideTabDisable.start()
        } else {
            simulationSummary.width = 0
            editorTab.visible = false
            simulationSummary.visible = false
            focusMode = true
            tabDisable.showTabDisable.start()
        }
    }

    Item {
        id: shortcutes
        Shortcut {
            // Random placement here because it could not find the editor otherwise (Qt bug?)
            sequence: "Ctrl+R"
            onActivated: editorTab.lammpsEditor.runScript()
        }
        Shortcut {
            sequence: "Ctrl+1"
            onActivated: tabView.currentIndex = 0
        }
        Shortcut {
            sequence: "Ctrl+2"
            onActivated: tabView.currentIndex = 1
        }
        Shortcut {
            sequence: "Tab"
            onActivated: toggleFocusMode()
        }
        Shortcut {
            sequence: "+"
            onActivated: {
                if(simulator.simulationSpeed < 100) {
                    simulator.setSimulationSpeed(simulator.simulationSpeed+1)
                }
            }
        }
        Shortcut {
            sequence: "-"
            onActivated: {
                if(simulator.simulationSpeed > 1) {
                    simulator.setSimulationSpeed(simulator.simulationSpeed-1)
                }
            }
        }
        Shortcut {
            sequence: "1"
            onActivated: {
                var isVisible = simulator.atomStyle.isVisible(0)
                simulator.atomStyle.setModelData(0, "visible", !isVisible)
            }
        }
        Shortcut {
            sequence: "2"
            onActivated: {
                var isVisible = simulator.atomStyle.isVisible(1)
                simulator.atomStyle.setModelData(1, "visible", !isVisible)
            }
        }
        Shortcut {
            sequence: "3"
            onActivated: {
                var isVisible = simulator.atomStyle.isVisible(2)
                simulator.atomStyle.setModelData(2, "visible", !isVisible)
            }
        }
    }

    DisableMessage {
        id: tabDisable
        x: parent.width*0.5 - 0.5*width
        y: 10
    }

    ControlBar {
        id: controlBar1
        simulator: desktopRoot.simulator
        visualizer: desktopRoot.visualizer
        visible: !desktopRoot.focusMode
        x: visualizer.x + visualizer.width*0.5 - 0.5*width

        y: parent.height - 100
        width: 300
        height: 50
    }
}
