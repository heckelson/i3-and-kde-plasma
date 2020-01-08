# i3-and-kde
How to install the i3 window manager on KDE

# Situation before installation
* Manjaro KDE Edition, all updates installed
* KDE plasma
* KWin

# Installation
## Packages
We're gonna install a couple packages that are required or nice-to-haves on i3. This consists of:
* ```i3-gaps```, obviously
* ```feh``` to set up the background
* ```i3-dmenu-desktop``` (not required)
* ```morc_menu``` if you don't want to use the KDE status bar
* ```i3-status``` for the status bar of i3
* ```wmctrl``` to add to the i3 config (if you're not on an English installation of Plasma)

Here's how I installed everything:
```$ sudo pacman -S i3-gaps feh i3-dmenu-desktop morc_menu i3-status wmctrl```

# Configuration
## Create a new XSession
Create a new file called plasma-i3.desktop in the /usr/share/xsessions directory as su.

Write the following into /usr/share/xsessions/plasma-i3.desktop :
```
[Desktop Entry]
Type=XSession
Exec=env KDEWM=/usr/bin/i3 /usr/bin/startplasma-x11
DesktopNames=KDE
Name=Plasma with i3
Comment=Plasma with i3
```

For the following use your existing i3 config or create a new config using  ```$ i3-config-wizard```.

Your i3 config should be located at ~/.config/i3/config.

## Adding stuff to the i3 config
To improve compatibility with Plasma, add the following lines in your i3 config.

```
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
for_window [class="plasmashell" window_type="notification"] floating enable, border none, move right 700px, move down 450px, no_focus
```
## Killing the existing plasma desktop that covers everything

Now with my installation, there was a Plasma Desktop window that covered everything and had to be closed with $mod+Shift+q every time I logged in. To circumvent that, follow this tutorial.

If you're on an English installation of Plasma, add this line to your i3 config:
```for_window [title="Desktop — Plasma"] kill; floating enable; border none```

If you're not on an English installation, do this. (This example is using the German Plasma installation)
### Find out the name of your plasma desktop window
After logging into your i3 environment, switch to a new workspace with $mod+2.Then enter the following in your terminal:
```$ wmctrl -l```

The output should contain the name of the plasma desktop window. 
```
0x04400006  0 alex-mi Arbeitsfläche — Plasma
...
```

Using this new-found information, add the following lines to your i3 config:
```
for_window [title="Desktop — Plasma"] kill; floating enable; border none
for_window [title="Arbeitsfläche — Plasma"] kill; floating enable; border none
```

## Background
By default, i3 doesn't set a background and it requires a third party to do that. I am using the default background provided by the Plasma theme with the name of "Andromeda".

I installed these following packages:
```$ sudo pacman -S andromeda-wallpaper plasma5-themes-andromeda sddm-andromeda-theme andromeda-icon-theme```
and enabled everything up in the Plasma settings.

To set up the same wallpaper in i3, add the following line to the i3 config:
```
exec --no-startup-id feh --bg-scale /usr/share/plasma/look-and-feel/org.manjaro.andromeda.desktop/contents/components/artwork/background.png
```

I hope this helped you with your Plasma i3 installation! Thanks for reading!
