/*
    SPDX-FileCopyrightText: 2022 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.0
import QtQuick.Controls 2.5 as QC2
import QtQuick.Layouts 1.12 as QtLayouts
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

QtLayouts.ColumnLayout {
    id: generalPage

    signal configurationChanged

    property alias cfg_leftClickAction: leftClickAction.currentIndex
    property alias cfg_rightClickAction: rightClickAction.currentIndex
    property alias cfg_scrollWheelOn: scrollWheelOn.checked

    property alias cfg_desktopWrapOn: desktopWrapOn.checked
    property alias cfg_singleRow: singleRow.checked

    property alias cfg_dotSize: dotSize.currentIndex
    property alias cfg_dotSizeCustom: dotSizeCustom.value

    property alias cfg_dotType: dotType.currentIndex
    property alias cfg_activeDot: activeDot.text
    property alias cfg_inactiveDot: inactiveDot.text

    Kirigami.FormLayout {
        QtLayouts.Layout.fillWidth: true
        
        QtLayouts.RowLayout {
            Kirigami.FormData.label: i18n("Left click action:")
            
            QC2.ComboBox {
                id: leftClickAction
                model: [
                    i18n("Do nothing"),
                    i18n("Switch to next desktop"),
                    i18n("Switch to previous desktop"),
                    i18n("Go to clicked desktop"),
                    i18n("Show desktop overview"),
                ]
                onActivated: cfg_leftClickAction = currentIndex
            }
        }
        
        QtLayouts.RowLayout {
            Kirigami.FormData.label: i18n("Right click action:")
            
            QC2.ComboBox {
                id: rightClickAction
                model: [
                    i18n("Do nothing"),
                    i18n("Switch to next desktop"),
                    i18n("Switch to previous desktop"),
                    i18n("Show desktop overview"),
                ]
                onActivated: cfg_rightClickAction = currentIndex
                enabled: leftClickAction.currentIndex != 3 
            }
        }

        QC2.CheckBox {
            id: scrollWheelOn
            text: i18n("Scrollwheel switches desktops")
        }
    
        Item {
            Kirigami.FormData.isSection: true
        }

        QtLayouts.ColumnLayout {
            Kirigami.FormData.label: i18n("Navigation behaviour:")
            Kirigami.FormData.buddyFor: desktopWrapOff

            QC2.RadioButton {
                id: desktopWrapOff
                text: i18n("Standard")
            }

            QC2.RadioButton {
                id: desktopWrapOn
                text: i18n("Wraparound")
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QtLayouts.ColumnLayout {
            Kirigami.FormData.label: i18n("Desktop Rows:")
            Kirigami.FormData.buddyFor: singleRow

            QC2.RadioButton {
                id: singleRow
                text: i18n("Single row")
            }

            QC2.RadioButton {
                id: multiRow
                text: i18n("Follow Plasma setting")
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QtLayouts.RowLayout {
            Kirigami.FormData.label: i18n("Indicator Dot Size:")

            QC2.ComboBox {
                id: dotSize
                model: [
                    i18n("Default"),
                    i18n("Scale with panel size"),
                    i18n("Custom Size")
                ]
            }

            QC2.SpinBox {
                id: dotSizeCustom
                textFromValue: function(value) {
                    return i18n("%1 px", value)
                }
                valueFromText: function(text) {
                    return parseInt(text)
                }
                from: PlasmaCore.Theme.defaultFont.pixelSize
                to: 72
                enabled: dotSize.currentIndex == 2
            }
        }

        QtLayouts.GridLayout {
            id: dotCharGrid
            columns: 3
            QtLayouts.Layout.fillWidth: true

            Kirigami.FormData.label: i18n("Indicator Dot Type:")
            Kirigami.FormData.buddyFor: dotType
    
            QC2.ComboBox {
                id: dotType
                model: [
                    i18n("Dot (Default)"),
                    i18n("Custom")
                ]
                onActivated: cfg_dotType = currentIndex
            }

            QC2.Label {
                text: i18n("Active Dot:")
                QtLayouts.Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                visible: dotType.currentIndex == 1
            }

            QC2.TextField {
                id: activeDot
                QtLayouts.Layout.maximumWidth: 35
                maximumLength: 1
                text: Plasmoid.configuration.activeDot
                horizontalAlignment: TextInput.AlignHCenter
                visible: dotType.currentIndex == 1
            }        

            Item {
                width: 5
            }
        
            QC2.Label {
                text: i18n("Inactive Dot:")
                QtLayouts.Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                visible: dotType.currentIndex == 1
            }

            QC2.TextField {
                id: inactiveDot
                QtLayouts.Layout.maximumWidth: 35
                maximumLength: 1
                text: Plasmoid.configuration.inactiveDot
                horizontalAlignment: TextInput.AlignHCenter
                visible: dotType.currentIndex == 1
            }         
        }
    }

    Kirigami.Separator {
        QtLayouts.Layout.fillWidth: true
        QtLayouts.Layout.topMargin: Kirigami.Units.largeSpacing * 1
        QtLayouts.Layout.bottomMargin: Kirigami.Units.largeSpacing * 0.5
    }

    QC2.Label {
        QtLayouts.Layout.fillWidth: true
        QtLayouts.Layout.leftMargin: Kirigami.Units.largeSpacing * 2
        QtLayouts.Layout.rightMargin: Kirigami.Units.largeSpacing * 2
        text: i18n("When using custom indicator types, ensure your theme's font supports your desired character to prevent widget display issues.")
        font: Kirigami.Theme.smallFont
        wrapMode: Text.Wrap
    }
        
    Item {
        QtLayouts.Layout.fillHeight: true
    }

    Component.onCompleted: {
        if (Plasmoid.configuration.scrollWheelOn) {
            scrollWheelOn.checked = true;
        }
        if (!Plasmoid.configuration.desktopWrapOn) {
            desktopWrapOff.checked = true;
        }
        if (!Plasmoid.configuration.singleRow) {
            multiRow.checked = true;
        }
        if (Plasmoid.configuration.dotType == 0) {
            activeDot.text = "●"
            inactiveDot.text = "○"  
        }
    }
}