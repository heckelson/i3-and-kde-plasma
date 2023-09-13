# i3 and KDE Plasma

How to install the i3 window manager on KDE Plasma.

> Preview image:
> ![screenshot of my current setup](images/Screenshot_20200109_150620.png)

---

## Situation before the installation

* Manjaro KDE Edition, all updates installed
* KDE Plasma
* KWin

---

## Installation

### Packages

We're gonna install a couple packages that are required or nice-to-haves on i3, as well as i3 itself. This consists of:

* ```i3```, obviously
* ```feh``` to set up the background
* ```dmenu``` (not required, but nice to have)
* ```wmctrl``` to get some info for the i3 config (if you're not on an English installation of Plasma)

Here's a oneliner on how I installed everything:
```$ sudo pacman -Syu && sudo pacman -S i3 feh i3-dmenu-desktop morc_menu wmctrl```

---

## Configuration

Check your Plasma version by running:

```sh
plasmashell --version
```

If you are using Plasma >=5.25, you can either
(i) create a new systemd user service to run i3 instead of KWin upon login (see option 1) or
(ii) you can also disable systemd startup and proceed with option 2, creating a new XSession. Option 1 is per-user, whereas option 2 is systemwide and requires root.

If you are using Plasma <5.25, you need to create a new XSession and login to that, which means only option 2 is available for you.

<details>
<summary>Option 1: systemd user service (Plasma >=5.25)</summary>

---
Note that for this method, you do not need to be the root user. However, that means the changes will not effect the other users.

Create a new service file called plasma-i3.service in `$HOME/.config/systemd/user`.

Write the following into `$HOME/.config/systemd/user/plasma-i3.service`:

```conf
[Unit]
Description=Launch Plasma with i3
Before=plasma-workspace.target

[Service]
ExecStart=/usr/bin/i3
Restart=on-failure

[Install]
WantedBy=plasma-workspace.target
```

Mask `plasma-kwin_x11.service` by running
```systemctl mask plasma-kwin_x11.service --user```

Enable the plasma-i3 service by running
```systemctl enable plasma-i3 --user```

To go back to KWin, just unmask the `plasma-kwin_x11.service` and disable your `plasma-i3` service in the same way.

---
</details>

<details>
<summary>Option 2: New XSession</summary>

---

Create a new file called `plasma-i3.desktop` in the `/usr/share/xsessions` directory as superuser.

Write the following into `/usr/share/xsessions/plasma-i3.desktop`:

```conf
[Desktop Entry]
Type=XSession
Exec=env KDEWM=/usr/bin/i3 /usr/bin/startplasma-x11
DesktopNames=KDE
Name=Plasma with i3
Comment=Plasma with i3
```

The i3 installation could have installed other .desktop files, you can remove them if you'd like. I only have the default `plasma.desktop` and `plasma-i3.desktop` in my folder.

For the following use your existing i3 config or create a new config using  ```$ i3-config-wizard``` (this also works when you're still in KWin).

Your i3 config should be located at `~/.config/i3/config`, although other locations are possible (depending on your personal configuration).

If you are on Plasma 5.25 or later, you need to configure Plasma, disabling the systemd startup.

```sh
$ kwriteconfig5 --file startkderc --group General --key systemdBoot false
$
```

---
</details>

### Adding stuff to the i3 config

To improve compatibility with Plasma, add the following lines in your i3 config.

```sh
# Plasma compatibility improvements
for_window [window_role="pop-up"] floating enable
for_window [window_role="task_dialog"] floating enable

for_window [class="yakuake"] floating enable
for_window [class="systemsettings"] floating enable
for_window [class="plasmashell"] floating enable;
for_window [class="Plasma"] floating enable; border none
for_window [title="plasma-desktop"] floating enable; border none
for_window [title="win7"] floating enable; border none
for_window [class="krunner"] floating enable; border none
for_window [class="Kmix"] floating enable; border none
for_window [class="Klipper"] floating enable; border none
for_window [class="Plasmoidviewer"] floating enable; border none
for_window [class="(?i)*nextcloud*"] floating disable
for_window [class="plasmashell" window_type="notification"] border none, move position 70 ppt 81 ppt
no_focus [class="plasmashell" window_type="notification"]
```

### Killing the existing window that covers everything

With my installation, there was a Plasma Desktop window that covered everything and had to be closed with $mod+Shift+q every time I logged in. To circumvent that, follow this tutorial.

<details>
<summary>English Plasma settings instructions</summary>

---

If you're on an English installation of Plasma, add this line to your i3 config:

For Plasma >=5.27

```for_window [title="Desktop @ QRect.*"] kill; floating enable; border none```

OR for Plasma <5.27

```for_window [title="Desktop — Plasma"] kill; floating enable; border none```

---
</details>

<details>
<summary>Non-English Plasma settings instructions</summary>

---

If you're not on the English setting, do this instead. This example is using the German Plasma setting.

#### Find out the name of your Plasma desktop

Directly after logging into your i3 environment, switch to a new workspace with $mod+2. Then enter the following in your terminal:

```$ wmctrl -l```

The output should contain the name of the Plasma window. Copy the name into your clipboard.

```
...
0x04400006  0 alex-mi Arbeitsfläche — Plasma
...
```

#### Set it in the i3 config

Using the name from the clipboard as te title, add the following lines to your i3 config:

```
for_window [title="Desktop — Plasma"] kill; floating enable; border none
for_window [title="Arbeitsfläche — Plasma"] kill; floating enable; border none
```

---
</details>

### Disabling a shortcut that breaks stuff

Launch the Plasma System Settings and go to *Category Workspace > Shortcuts > Category System Services > Plasma* and disable the shortcut "Activities..." that uses the combination ```Meta+Q```.

### Using the plasma shutdown screen

To use the plasma shutdown/logout/reboot screen, delete this line (or comment out)

```
bindsym $mod+Shift+e exec "i3-nagbar " ...
```

and add the following one(s) instead:

<details>
<summary>For KDE 4</summary>

---

```sh
# using plasma's logout screen instead of i3's
bindsym $mod+Shift+e exec --no-startup-id qdbus org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.logout -1 -1 -1
```

---
</details>

<details>
<summary>For KDE 5</summary>

---

```sh
# using plasma's logout screen instead of i3's
bindsym $mod+Shift+e exec --no-startup-id qdbus-qt5 org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.logout -1 -1 -1
```

*Note: With some distros, even if you have KDE 5 and Qt 5, the above line may not work and would require calling ```qdbus``` instead of ```qdbus-qt5```, as shown under KDE 4.*

---
</details>

### Audio buttons integration

To control the volume via DBus with nice popups and sounds, you can add the following lines to the i3config:

```sh
bindsym XF86AudioRaiseVolume exec --no-startup-id qdbus org.kde.kglobalaccel /component/kmix invokeShortcut "increase_volume"
bindsym XF86AudioLowerVolume exec --no-startup-id qdbus org.kde.kglobalaccel /component/kmix invokeShortcut "decrease_volume"
bindsym XF86AudioMute exec --no-startup-id qdbus org.kde.kglobalaccel /component/kmix invokeShortcut "mute"
bindsym XF86AudioMicMute exec --no-startup-id qdbus org.kde.kglobalaccel /component/kmix invokeShortcut "mic_mute"
```

---

# Personal config

## Packages:

* ```picom-git```, blur effecct (from aur)
* ```plasma5-applets-redshift-control-git```, night mode (from aur)
* ```ulauncher```, applications launcher (from aur)
* ```rofi```, alternative dmenu (from pacman)
* ```kvantum```, theme engine (from pacman)
* ```libdbusmenu-glib```, fix global menu vscode (from pacman)
* ```fd```, find file (from pacman)
* ```fzf```, fuzzer finder (from pacman)

## Plasmoids
* ```Application title```
* ```Minimal Desktop Indicator```
* ```Better inline clock```

## Theme & font
Application Style ```kvantum```  
Splash Screen ```none```  
Plasma Style ```ROUNDED COLOR```  
Colors ```Sweet```  
Icons ```Miya-dark```  
SDDM ```Sugar Candy``` and set at ```/usr/share/sddm/themes/sugar-candy/theme.conf``` file ```PartialBlur="false"``` for disable blur & use ```boot.jpg``` image  
Screen Locking add ```boot.jpg``` image

Install ```Roboto``` & ```FiraCode``` fonts  
For ```general```, ```Toolbar```, ```Menu```  use ```Roboto regular 10pt```  
For ```Window title``` use ```Roboto medium 10pt```  
For ```small``` use ```Roboto regular 8pt```  
For ```Fixed width``` use ```Fira Code Retina 10pt```  
### Kvantum:  
Install ```Sweet-Mars-transparent-toolbar``` theme  
Disable translucency with non-integer scaling  
Reduce window opacity by 5%  
### Ulauncher
Theme: ```Transparent Adwaita```  
Launch the Plasma System Settings and go to *Startup and Shutdown > Autostart* and add at ulauncher ```--no-window-shadow``` with arguments  
Install fuzzy finder extension
  
# Configuration

* copy ```rofi``` & ```i3``` folders in ```~/.config/``` folder  
* copy ```walpapers``` & ```plasma folders``` in ```~/.local/share/``` folder  
* General Behavior set ```select them```  
* Touchpad set ```Invert scroll direction```  
* Desktop Session ser ```Start with a empty session```  
## Change position volume pop-up
* Create a new ```togglepopup.service``` service file in the /etc/systemd/system directory.  
* Add the following lines to the service file:  
```conf
[Unit]
Description=Fix file Osd.qml
After=network.target

[Service]
ExecStart=/home/luigi/.local/share/plasma/toggle-for-pop-up.sh
Restart=always
User=root
Group=root
Type=simple

[Install]
WantedBy=multi-user.target
```  
* Save and exit  
* Reload ```sudo systemctl daemon-reload```  
* Enable ```sudo systemctl enable togglepopup.service```
* Start ```sudo systemctl start togglepopup.service```
* Reboot
