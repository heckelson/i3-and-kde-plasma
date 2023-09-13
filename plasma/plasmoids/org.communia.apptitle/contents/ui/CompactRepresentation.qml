/*
 *   Copyright 2012-2013 Andrea Scarpino <scarpino@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Lesser General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import org.kde.taskmanager 0.1 as TaskManager
//import org.kde.qtextracomponents 2.0 as QtExtraComponents

Item {
    id: main

    Layout.minimumWidth : plasmoid.formFactor == PlasmaCore.Types.Horizontal ? height : 1
    Layout.minimumHeight : plasmoid.formFactor == PlasmaCore.Types.Vertical ? width  : 1
    //property int minimumWidth: row.implicitWidth
    //property int minimumHeight: appLabel.paintedHeight
    implicitWidth: row.implicitWidth
    width: row.implicitWidth
    height:row.implicitHeight

    anchors.fill: parent

    // Config
    property bool show_application_icon: true
    property bool show_window_title: true
    property bool use_fixed_width: plasmoid.configuration.useFixedWidth
    property int textType: plasmoid.configuration.textType

    // Window properties
    property bool noWindowActive: true
    property bool currentWindowMaximized: false
    property bool isActiveWindowPinned: false
    property bool isActiveWindowMaximized: false


//    Component.onCompleted: {
//        plasmoid.addEventListener("ConfigChanged", configChanged)
//    }

//    function configChanged() {
//        show_application_icon = plasmoid.configuration.showApplicationIcon
//        show_window_title = plasmoid.readConfig("showWindowTitle")
//        use_fixed_width = plasmoid.configuration.fixedWidth

//        appLabel.font.family = plasmoid.readConfig("font").toString().split(',')[0]
//        appLabel.font.italic = plasmoid.readConfig("italic")
//        appLabel.font.underline = plasmoid.readConfig("underline")
//        appLabel.color = plasmoid.readConfig("color")

//        if (plasmoid.readConfig("bold") == true) {
//            appLabel.font.weight = Font.Bold
//        } else {
//            appLabel.font.weight = Font.Normal
//        }
//    }
        //
        // MODEL
        //
        TaskManager.TasksModel {
          id: tasksModel
          sortMode: TaskManager.TasksModel.SortVirtualDesktop
          groupMode: TaskManager.TasksModel.GroupDisabled
          
          screenGeometry: plasmoid.screenGeometry

          onActiveTaskChanged: {
            activeWindowModel.sourceModel = tasksModel
            updateActiveWindowInfo()
          }
          onDataChanged: {
            updateActiveWindowInfo()
          }
        }
        
        // should return always one item
        PlasmaCore.SortFilterModel {
          id: activeWindowModel
          filterRole: 'IsActive'
          filterRegExp: 'true'
          sourceModel: tasksModel
          onDataChanged: {
            updateActiveWindowInfo()
          }
          onCountChanged: {
            updateActiveWindowInfo()
          }
        }
        function activeTask() {
          return activeWindowModel.get(0) || {}
        }        
        function updateActiveWindowInfo() {
          appLabel.visible = activeWindowModel.count != 0
          var actTask = activeTask()
          //console.warn(actTask.AppName)
          noWindowActive = activeWindowModel.count === 0 || actTask.IsActive !== true
             currentWindowMaximized = !noWindowActive && actTask.IsMaximized === true
             isActiveWindowPinned = actTask.VirtualDesktop === -1;
             if (noWindowActive) {
                 appLabel.text = plasmoid.configuration.noWindowText
                 iconItem.source = "" //plasmoid.configuration.noWindowIcon
        } else {
          appLabel.text = textType === 1 ? actTask.AppName : replaceTitle(actTask.display)
          iconItem.source = actTask.decoration
        }
             //parent.width=width
             return
            if (use_fixed_width) {
                main.width = plasmoid.configuration.fixedWidth
                if (show_application_icon) {
                  //appLabel.width = main.width - row.spacing - iconItem.width
                  appLabel.width = plasmoid.configuration.fixedWidth - row.spacing - iconItem.width
                  console.warn("With icon Set width to " + appLabel.width)
                } else {
                    appLabel.width = main.width
                    console.warn("Set width to " + appLabel.width)
                }
                appLabel.elide = Text.ElideRight
            } else {
              console.warn("no fixed width")
                if (plasmoid.configuration.showApplicationIcon) {
                    main.width = iconItem.width + row.spacing + appLabel.paintedWidth
                } else {
                    main.width = appLabel.paintedWidth
                }
                appLabel.width = appLabel.paintedWidth
                appLabel.elide = Text.ElideNone
              console.warn(appLabel.width)
            } 
        
        
        }
        function replaceTitle(title) {
          if (!plasmoid.configuration.useWindowTitleReplace) {
            return title
          }
          return title.replace(new RegExp(plasmoid.configuration.replaceTextRegex), plasmoid.configuration.replaceTextReplacement);
        } 

    Row {
        id: row
        spacing: 3
        //anchors.centerIn: parent

        PlasmaCore.IconItem {
            id: iconItem
            height: appLabel.paintedHeight
            width: height
            visible: show_application_icon
            anchors.verticalCenter: appLabel.verticalCenter
      }

        PlasmaComponents.Label {
            id: appLabel
            text: "HI WORLD"
            wrapMode: Text.Wrap
        }
    }
}
