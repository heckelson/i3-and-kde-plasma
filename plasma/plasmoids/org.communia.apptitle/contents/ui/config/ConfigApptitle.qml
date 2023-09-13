import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

GridLayout {
    id: main

    property alias cfg_showApplicationIcon: showApplicationIcon.checked
    property alias cfg_showWindowTitle: showWindowTitle.checked
    property alias cfg_useFixedWidth: useFixedWidth.checked
    property alias cfg_fixedWidth: fixedWidth.value
    property alias cfg_noWindowText: noWindowText.text
    property alias cfg_noWindowType: noActiveType.currentIndex
    property alias cfg_textType: textTypeCombo.currentIndex
    property alias cfg_useWindowTitleReplace: useWindowTitleReplace.checked
    property alias cfg_replaceTextRegex: replaceTextRegex.text
    property alias cfg_replaceTextReplacement: replaceTextReplacement.text
    property alias cfg_bold: bold.checked
    property alias cfg_capitalize: capitalize.checked

    anchors.rightMargin: 0
    anchors.bottomMargin: 0
    anchors.leftMargin: 0
    anchors.topMargin: 0
    rows: 1
    columns: 2
    anchors.fill: parent

    CheckBox {
        id: showApplicationIcon
        text: qsTr("Show the application icon")
        //enabled:false
    }
    CheckBox {
        id: showWindowTitle
        text: qsTr("Show Window Title")
        checked: true
        enabled:false

    }
    CheckBox {
        id: useFixedWidth
        text: qsTr("Use fixed width")
    }

    SpinBox {
        id: fixedWidth
        minimumValue: 100
        maximumValue: 1000
        enabled: useFixedWidth.checked
        Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 12
    }

    Label {
        id: labelNoActiveType
        text: qsTr("No active window label")
    }

    RowLayout {
        id: rowLayout
        width: 100
        height: 100

        ComboBox {
            id: noActiveType
            model: [i18n('Activity name'),i18n('Desktop name'), i18n('Custom text')]
        }
    }


    Label {
        id: label
        text: qsTr("No active window custom text:")
    }


    TextField {
        id: noWindowText
        text: qsTr("Text Input")
        Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 12
        enabled: noActiveType.currentIndex === 2
    }
    Label {
        text: i18n('Text type:')
    }
    ComboBox {
        id: textTypeCombo
        model: [i18n('Window title'), i18n('Application name')]
        Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 12
    }

    CheckBox {
        id: useWindowTitleReplace
        text: '"' + i18n('Window title') + '".replace(/'
        Layout.alignment: Qt.AlignRight
    }
    GridLayout {
        columns: 4

        TextField {
            id: replaceTextRegex
            placeholderText: '^(.*)\\s+[—–\\-:]\\s+([^—–\\-:]+)$'
            Layout.preferredWidth: 300
            onTextChanged: cfg_replaceTextRegex = text
            enabled: useWindowTitleReplace.checked
        }

        Label {
            text: '/, "'
        }

        TextField {
            id: replaceTextReplacement
            placeholderText: '$2 — $1'
            Layout.preferredWidth: 100
            onTextChanged: cfg_replaceTextReplacement = text
            enabled: useWindowTitleReplace.checked
        }

        Label {
            text: '");'
        }
    }
    GridLayout{
        columns: 3
        CheckBox{
            id: bold
            text: qsTr("Bold")
            checked: cfg_bold
        }
        CheckBox{
            id: capitalize
            text: qsTr("Capitalize")
            checked: cfg_capitalize
        }
    }



}
