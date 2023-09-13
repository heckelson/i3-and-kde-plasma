/*
 * Copyright 2013 Heena Mahour <heena393@gmail.com>
 * Copyright 2013 Sebastian Kügler <sebas@kde.org>
 * Copyright 2013 Martin Klapetek <mklapetek@kde.org>
 * Copyright 2014 David Edmundson <davidedmundson@kde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.6
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as Components
import org.kde.plasma.private.digitalclock 1.0

Item {
    id: main

    Layout.fillHeight: true
    Layout.fillWidth: false
    Layout.minimumWidth: paintArea.width
    Layout.maximumWidth: Layout.minimumWidth

    property string timeFormat
    property date currentTime
    property bool showSeconds: plasmoid.configuration.showSeconds
    property bool showLocalTimezone: plasmoid.configuration.showLocalTimezone
    property bool showDate: plasmoid.configuration.showDate
    property bool showSeparator: plasmoid.configuration.showSeparator
    property bool fixedFont: plasmoid.configuration.fixedFont
    property var dateFormat: {
        if (plasmoid.configuration.dateFormat === "customDate") {
            return plasmoid.configuration.customDateFormat;
        } else if (plasmoid.configuration.dateFormat === "longDate") {
            return Qt.SystemLocaleLongDate;
        } else if (plasmoid.configuration.dateFormat === "isoDate") {
            return Qt.ISODate;
        } else if (plasmoid.configuration.dateFormat === "qtDate") {
            return Qt.TextDate;
        } else if (plasmoid.configuration.dateFormat === "rfcDate") {
            return Qt.RFC2822Date;
        } else {
            return Qt.SystemLocaleShortDate; }}

    property string lastSelectedTimezone: plasmoid.configuration.lastSelectedTimezone
    property bool displayTimezoneAsCode: plasmoid.configuration.displayTimezoneAsCode
    property int use24hFormat: plasmoid.configuration.use24hFormat
    property int fontSize: plasmoid.configuration.fontSize
    property string lastDate: ""
    property int tzOffset
    property int tzIndex: 0
    readonly property bool oneLineMode: plasmoid.formFactor == PlasmaCore.Types.Horizontal &&
                                        main.height <= 2 * theme.smallestFont.pixelSize &&
                                        (main.showDate || timezoneLabel.visible)

    onDateFormatChanged:            { setupLabels(); }
    onDisplayTimezoneAsCodeChanged: { setupLabels(); }

    onLastSelectedTimezoneChanged: { timeFormatCorrection(Qt.locale().timeFormat(Locale.ShortFormat)) }
    onShowSecondsChanged:          { timeFormatCorrection(Qt.locale().timeFormat(Locale.ShortFormat)) }
    onShowLocalTimezoneChanged:    { timeFormatCorrection(Qt.locale().timeFormat(Locale.ShortFormat)) }
    onShowDateChanged:             { timeFormatCorrection(Qt.locale().timeFormat(Locale.ShortFormat)) }
    onUse24hFormatChanged:         { timeFormatCorrection(Qt.locale().timeFormat(Locale.ShortFormat)) }

    Connections {
        target: plasmoid
        onContextualActionsAboutToShow: {
            ClipboardMenu.secondsIncluded = main.showSeconds;
            ClipboardMenu.currentDate = main.currentTime; }}

    Connections {
        target: plasmoid.configuration
        onSelectedTimeZonesChanged: {
            var lastSelectedTimezone = plasmoid.configuration.lastSelectedTimezone;
            if (plasmoid.configuration.selectedTimeZones.indexOf(lastSelectedTimezone) == -1) {
                plasmoid.configuration.lastSelectedTimezone = plasmoid.configuration.selectedTimeZones[0]; }
            setupLabels();
            setTimezoneIndex(); }}

    MouseArea {
        id: mouseArea

        property int wheelDelta: 0
        anchors.fill: parent
        onClicked: plasmoid.expanded = !plasmoid.expanded
        onWheel: {
            if (!plasmoid.configuration.wheelChangesTimezone) {
                return; }
            var delta = wheel.angleDelta.y || wheel.angleDelta.x
            var newIndex = main.tzIndex;
            wheelDelta += delta;
            while (wheelDelta >= 120) {
                wheelDelta -= 120;
                newIndex--; }
            while (wheelDelta <= -120) {
                wheelDelta += 120;
                newIndex++; }
            if (newIndex >= plasmoid.configuration.selectedTimeZones.length) {
                newIndex = 0; } else if (newIndex < 0) {
                newIndex = plasmoid.configuration.selectedTimeZones.length - 1; }
            if (newIndex !== main.tzIndex) {
                plasmoid.configuration.lastSelectedTimezone = plasmoid.configuration.selectedTimeZones[newIndex];
                main.tzIndex = newIndex;
                dataSource.dataChanged();
                setupLabels(); }}}

    property font font: Qt.font({
            family: plasmoid.configuration.fontFamily || theme.defaultFont.family,
            weight: plasmoid.configuration.boldText ? Font.Bold : theme.defaultFont.weight,
            italic: plasmoid.configuration.italicText,
            pixelSize: fixedFont ? fontSize : 1024 })

    // -------------
    // BEGIN VISIBLE
    Row {
        id: paintArea

        spacing: plasmoid.configuration.customSpacing * 2
        leftPadding: spacing
        rightPadding: spacing
        
        anchors {
            centerIn: parent
            horizontalCenterOffset: plasmoid.configuration.customOffsetX - 50
            verticalCenterOffset: -plasmoid.configuration.customOffsetY
        }

        Components.Label {
            id: dateLabel

            height: timeLabel.height
            width: dateLabel.paintedWidth
            font: main.font
            fontSizeMode: fixedFont ? Text.FixedSize : Text.VerticalFit
            minimumPixelSize: 1
            visible: main.showDate
        }

        Components.Label {
            id: separator

            height: timeLabel.height
            width: separator.paintedWidth
            font: main.font
            fontSizeMode: fixedFont ? Text.FixedSize : Text.VerticalFit
            minimumPixelSize: 1
            transform: Translate { y: separator.paintedHeight / -15 }
            visible: dateLabel.visible && plasmoid.configuration.showSeparator
            text: "|"
        }

        Components.Label  {
            id: timeLabel

            height: sizehelper.height
            width: timeLabel.paintedWidth
            font: main.font
            fontSizeMode: fixedFont ? Text.FixedSize : Text.VerticalFit
            minimumPixelSize: 1
            text: {
                var now = dataSource.data[plasmoid.configuration.lastSelectedTimezone]["DateTime"];
                var msUTC = now.getTime() + (now.getTimezoneOffset() * 60000);
                var currentTime = new Date(msUTC + (dataSource.data[plasmoid.configuration.lastSelectedTimezone]["Offset"] * 1000));
                main.currentTime = currentTime;
                return Qt.formatTime(currentTime, main.timeFormat); }
        }

        Components.Label {
            id: timezoneLabel

            height: timeLabel.height
            width: timezoneLabel.paintedWidth
            font: main.font
            fontSizeMode: fixedFont ? Text.FixedSize : Text.VerticalFit
            minimumPixelSize: 1
            visible: text.length > 0
        }
    }
    // ENDOF VISIBLE

    Components.Label {
        id: sizehelper
        height: Math.min(main.height, 2.5 * theme.defaultFont.pixelSize)
        font.family: timeLabel.font.family
        font.weight: timeLabel.font.weight
        font.italic: timeLabel.font.italic
        font.pixelSize: fixedFont ? fontSize : 2.5 * theme.defaultFont.pixelSize
        fontSizeMode: fixedFont ? Text.FixedSize : Text.VerticalFit
        minimumPixelSize: 1
        visible: false }

    FontMetrics {
        id: timeMetrics
        font.family: timeLabel.font.family
        font.weight: timeLabel.font.weight
        font.italic: timeLabel.font.italic }


    function timeFormatCorrection(timeFormatString) {
        var regexp = /(hh*)(.+)(mm)/i
        var match = regexp.exec(timeFormatString);
        var hours = match[1];
        var delimiter = match[2];
        var minutes = match[3]
        var seconds = "ss";
        var amPm = "AP";
        var uses24hFormatByDefault = timeFormatString.toLowerCase().indexOf("ap") === -1;
        var result = hours.toLowerCase() + delimiter + minutes;
        if (main.showSeconds) {
            result += delimiter + seconds; }
        if ((main.use24hFormat == Qt.PartiallyChecked && !uses24hFormatByDefault) || main.use24hFormat == Qt.Unchecked) {
            result += " " + amPm; }
        main.timeFormat = result;
        setupLabels(); }

    function setupLabels() {
        var showTimezone = main.showLocalTimezone || (plasmoid.configuration.lastSelectedTimezone !== "Local" && dataSource.data["Local"]["Timezone City"] !== dataSource.data[plasmoid.configuration.lastSelectedTimezone]["Timezone City"]);
        var timezoneString = "";
        if (showTimezone) {
            timezoneString = plasmoid.configuration.displayTimezoneAsCode ? dataSource.data[plasmoid.configuration.lastSelectedTimezone]["Timezone Abbreviation"] : TimezonesI18n.i18nCity(dataSource.data[plasmoid.configuration.lastSelectedTimezone]["Timezone City"]);
            timezoneLabel.text = "(" + timezoneString + ")";
        } else { timezoneLabel.text = timezoneString; }
        if (main.showDate) { dateLabel.text = Qt.formatDate(main.currentTime, main.dateFormat);
        } else { dateLabel.text = ""; }
        var maximumWidthNumber = 0;
        var maximumAdvanceWidth = 0;
        for (var i = 0; i <= 9; i++) {
            var advanceWidth = timeMetrics.advanceWidth(i);
            if (advanceWidth > maximumAdvanceWidth) {
                maximumAdvanceWidth = advanceWidth;
                maximumWidthNumber = i; }}
        var format = main.timeFormat.replace(/(h+|m+|s+)/g, "" + maximumWidthNumber + maximumWidthNumber); // make sure maximumWidthNumber is formatted as string
        var date = new Date(2000, 0, 1, 1, 0, 0);
        var timeAm = Qt.formatTime(date, format);
        var advanceWidthAm = timeMetrics.advanceWidth(timeAm);
        date.setHours(13);
        var timePm = Qt.formatTime(date, format);
        var advanceWidthPm = timeMetrics.advanceWidth(timePm);
        if (advanceWidthAm > advanceWidthPm) { sizehelper.text = timeAm;
        } else { sizehelper.text = timePm; }}

    function dateTimeChanged() {
        var doCorrections = false;
        if (main.showDate) {
            var currentDate = Qt.formatDateTime(dataSource.data["Local"]["DateTime"], "yyyy-mm-dd");
            if (main.lastDate !== currentDate) {
                doCorrections = true;
                main.lastDate = currentDate }}
        var currentTZOffset = dataSource.data["Local"]["Offset"] / 60;
        if (currentTZOffset !== tzOffset) {
            doCorrections = true;
            tzOffset = currentTZOffset;
            Date.timeZoneUpdated(); }
        if (doCorrections) {
            timeFormatCorrection(Qt.locale().timeFormat(Locale.ShortFormat)); }}

    function setTimezoneIndex() {
        for (var i = 0; i < plasmoid.configuration.selectedTimeZones.length; i++) {
            if (plasmoid.configuration.selectedTimeZones[i] === plasmoid.configuration.lastSelectedTimezone) {
                main.tzIndex = i;
                break; }}}

    Component.onCompleted: {
        var sortArray = plasmoid.configuration.selectedTimeZones;
        sortArray.sort(function(a, b) { return dataSource.data[a]["Offset"] - dataSource.data[b]["Offset"]; });
        plasmoid.configuration.selectedTimeZones = sortArray;
        setTimezoneIndex();
        tzOffset = -(new Date().getTimezoneOffset());
        dateTimeChanged();
        timeFormatCorrection(Qt.locale().timeFormat(Locale.ShortFormat));
        dataSource.onDataChanged.connect(dateTimeChanged); }
}
