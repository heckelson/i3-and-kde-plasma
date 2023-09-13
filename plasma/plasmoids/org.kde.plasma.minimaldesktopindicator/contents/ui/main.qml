/*
    SPDX-FileCopyrightText: 2022 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents
import org.kde.plasma.private.pager 2.0

GridLayout {
    id: root

    property int scrollWheelDelta: 0

    rows: {
        if (Plasmoid.configuration.singleRow) {
            return 1;
        } else {
            return pagerModel.layoutRows;
        }
    }
    columns: {
        if (Plasmoid.configuration.singleRow) {
            return pagerModel.count;
        } else {
            return Math.ceil(pagerModel.count / pagerModel.layoutRows);
        }
    }
    columnSpacing: 0
    rowSpacing: 0

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    PagerModel {
        id: pagerModel

        enabled: root.visible
        screenGeometry: plasmoid.screenGeometry

        pagerType: PagerModel.VirtualDesktops
    }

    Repeater {
        id: indicatorRepeater
        model: pagerModel.count

        Rectangle {
            id: indicatorContainer
            
            color: "transparent"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: {
                if (Plasmoid.configuration.dotSize == 0) {
                    return PlasmaCore.Theme.defaultFont.pixelSize;
                } else if (Plasmoid.configuration.dotSize == 1) {
                    return indicatorDot.font.pixelSize;
                } else {
                    return Plasmoid.configuration.dotSizeCustom;
                }
            }
            Layout.minimumHeight: {
                if (!Plasmoid.configuration.dotSize == 2) {
                    return 0;
                } else {
                    return Plasmoid.configuration.dotSizeCustom;
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: {
                    if (Plasmoid.configuration.rightClickAction == 0) {
                        return Qt.LeftButton;
                    } else {
                        return Qt.LeftButton | Qt.RightButton;
                    }
                }
                z: {
                    if(Plasmoid.configuration.leftClickAction != 3) {
                        return 1;
                    } else {
                        return 0;
                    }
                }

                // TODO: Clean up and refactor this horrible, horrible mess
                onClicked: {
                    if (mouse.button === Qt.LeftButton && (Plasmoid.configuration.leftClickAction != 0 || Plasmoid.configuration.leftClickAction != 3)) {
                        if (Plasmoid.configuration.leftClickAction == 1) {
                            if (pagerModel.currentPage < pagerModel.count - 1) {
                                pagerModel.changePage(pagerModel.currentPage + 1);
                            } else if (Plasmoid.configuration.desktopWrapOn) {
                                pagerModel.changePage(0);
                            }
                        } else if (Plasmoid.configuration.leftClickAction == 2) {
                            if (pagerModel.currentPage > 0) {
                                pagerModel.changePage(pagerModel.currentPage - 1);
                            } else if (Plasmoid.configuration.desktopWrapOn) {
                                pagerModel.changePage(pagerModel.count - 1);
                            }
                        } else if (Plasmoid.configuration.leftClickAction == 4) {
                            exposeDesktop();
                        }
                    } else if (mouse.button === Qt.RightButton && (Plasmoid.configuration.rightClickAction != 0 || Plasmoid.configuration.leftClickAction != 3)) {
                        if (Plasmoid.configuration.rightClickAction == 1) {
                            if (pagerModel.currentPage < pagerModel.count - 1) {
                                pagerModel.changePage(pagerModel.currentPage + 1);
                            } else if (Plasmoid.configuration.desktopWrapOn) {
                                pagerModel.changePage(0);
                            }
                        } else if (Plasmoid.configuration.rightClickAction == 2) {
                            if (pagerModel.currentPage > 0) {
                                pagerModel.changePage(pagerModel.currentPage - 1);
                            } else if (Plasmoid.configuration.desktopWrapOn) {
                                pagerModel.changePage(pagerModel.count - 1);
                            }
                        } else if (Plasmoid.configuration.rightClickAction == 3) {
                            exposeDesktop();
                        }
                    }
                }

                // TODO: Clean up and refactor this not-quite-as-horrible mess
                onWheel: {
                    if (Plasmoid.configuration.scrollWheelOn) {
                        // TODO: Add user option to invert direction of y-axis scroll
                        scrollWheelDelta += wheel.angleDelta.x || wheel.angleDelta.y;
                        
                        let wheelStep = 0
                        
                        while (scrollWheelDelta <= 120) {
                            scrollWheelDelta += 120;
                            wheelStep--;
                        }
                        
                        while (scrollWheelDelta >= 120) {
                            scrollWheelDelta -= 120;
                            wheelStep++;
                        }
                        
                        while (wheelStep !== 0) {
                            if (wheelStep < 0) {
                                if (pagerModel.currentPage < pagerModel.count - 1) {
                                    pagerModel.changePage(pagerModel.currentPage + 1);
                                } else if (Plasmoid.configuration.desktopWrapOn) {
                                    pagerModel.changePage(0);
                                }
                            } else {
                                if (pagerModel.currentPage > 0) {
                                    pagerModel.changePage(pagerModel.currentPage - 1);
                                } else if (Plasmoid.configuration.desktopWrapOn) {
                                    pagerModel.changePage(pagerModel.count - 1);
                                }
                            }
                            wheelStep += (wheelStep < 0) ? 1 : -1;
                        }
                    }
                }
            }
            
            PlasmaComponents.Label {
                id: indicatorDot
                
                anchors.centerIn: parent
                font.pixelSize: {
                    if (Plasmoid.configuration.dotSize == 0) {
                        return PlasmaCore.Theme.defaultFont.pixelSize;
                    } else if (Plasmoid.configuration.dotSize == 1) {
                        //TODO: Consider adding state support for vertical panel users
                        return parent.height;
                    } else {
                        return Plasmoid.configuration.dotSizeCustom;
                    }
                }
                text: {
                    if (Plasmoid.configuration.dotType == 0) {
                        if (index == pagerModel.currentPage) {
                            return "●";
                        } else {
                            return "○";
                        }
                    } else {
                        if (index == pagerModel.currentPage) {
                            return Plasmoid.configuration.activeDot;
                        } else {
                            return Plasmoid.configuration.inactiveDot;
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (Plasmoid.configuration.leftClickAction == 3) {
                            pagerModel.changePage(index);
                        }
                    }
                    z: {
                        if (Plasmoid.configuration.leftClickAction != 3) {
                            return 0;
                        } else {
                            return 1;
                        }
                    }
                }
            }
        }
    }

    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: disconnectSource(sourceName)

        function exec(cmd) {
            executable.connectSource(cmd)
        }
    }

    function exposeDesktop() {
        executable.exec('qdbus org.kde.kglobalaccel /component/kwin invokeShortcut Overview')
    }
}
