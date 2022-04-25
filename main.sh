#!/bin/bash

############################################
#  \u2605 = Check mark
#  
#  adb exec-out screenrecord --output-format=h264 - | ffplay -framerate 60 -probesize 32 -sync video  -
#  
#  
#  
############################################
## Initila setup
unalias cp

echo $'\u0c93'"O"

echo -e "\n\e[1;33m          ++++++++++  ++++++++++ \e[1;34m"
echo -e "\n\e[1;33m          ++++++++++ Update Package DB ++++++++++ \e[1;34m"
sudo pacman -Sy
echo $'\u2714' "Package DataBase Updated"

A=$( uname -r | cut -d"." -f1 )
B=$( uname -r | cut -d"." -f2 )

echo -e "\n\e[1;33m          ++++++++++ Install needed packages ++++++++++ \e[1;00m"
sudo pacman -Su --needed keepassxc meld chromium \
                        conky rkhunter dnsutils \
                        base-devel redshift youtube-dl \
                        vim android-tools virtualbox \
                        linux${A}${B}-virtualbox-host-modules vagrant


echo -e "\n\e[1;33m          ++++++++++ Application COnfiguration ++++++++++ \e[1;34m"
xdg-mime default org.pwmt.zathura.desktop application/pdf

sudo pamac zoom virtualbox-ext-oracle sublime-text-4
echo $'\u2714' "Installed Required Packages"

echo -e "\n\e[1;33m          ++++++++++ Remove unwanted packages ++++++++++ \e[1;00m"
sudo pacman -Rnsc manjaro-steam xfce4-weather-plugin pidgin hexchat #xfce4-clipman-plugin
sudo pacman -Rdd geoclue geocode-glib
echo $'\u2714' "Removed Unwanted Packages"

chmod 755 files/*

echo -e "\n\e[1;33m          ++++++++++ Hardening system ++++++++++ \e[1;00m"
sudo cp ./files/99-manjaro.conf /etc/sysctl.d/99-manjaro.conf
sudo cp ./files/99-sysctl.conf /etc/sysctl.d/99-sysctl.conf
sudo cp ./files/51-kptr-restrict.conf /etc/sysctl.d/51-kptr-restrict.conf
sudo cp ./files/50-coredump.conf /etc/sysctl.d/50-coredump.conf
sudo cp ./files/52-filesystem.conf /etc/sysctl.d/52-filesystem.conf
sudo cp ./files/blacklist.conf /etc/modprobe.d/blacklist.conf
sudo cp ./files/90-external-mnt.rules /etc/polkit-1/rules.d/90-external-mnt.rules
sudo cp ./files/10-runtime-pm.rules /etc/udev/rules.d/10-runtime-pm.rules
sudo sysctl --system

echo -e "\n\e[1;33m          ++++++++++ Setting Grub Username and password ++++++++++ \e[1;00m"
read -p 'Username for GRUB: ' uservar
grub-mkpasswd-pbkdf2 | tee /tmp/out.txt
# echo $(grep -o 'grub.pbkdf2.*' out.txt)
# ls /etc/grub.d
echo "set superusers=\"$uservar\"" | sudo tee -a /etc/grub.d/40_custom > /dev/null
echo "password_pbkdf2 $uservar" $(grep -o 'grub.pbkdf2.*' /tmp/out.txt) | sudo tee -a /etc/grub.d/40_custom > /dev/null
echo $'\U2714' "GRUB Password configured"
rm /tmp/out.txt

if grep -q "CLASS=\"--class gnu-linux --class gnu --class os\"" "/etc/grub.d/10_linux"; then
  sudo sed -i 's/CLASS=\"--class gnu-linux --class gnu --class os\"/CLASS=\"--class gnu-linux --class gnu --class os --unrestricted\"/' "/etc/grub.d/10_linux"
  echo $'\u2714' "Unrestricted the GRUB password for Linux System"
fi

echo -e "\n\e[1;33m          ++++++++++ Changing file permissions ++++++++++ \e[1;00m"
sudo chmod 600 /boot/grub/grub.cfg
sudo chmod 600 /etc/cron.deny
sudo chmod 600 /etc/ssh/sshd_config
sudo chmod 700 /etc/cron.d
sudo chmod 700 /etc/cron.daily
sudo chmod 700 /etc/cron.hourly
sudo chmod 700 /etc/cron.weekly
sudo chmod 700 /etc/cron.monthly

echo -e "\n\e[1;33m          ++++++++++ Disable unwanted Services ++++++++++ \e[1;00m"
sudo systemctl disable snapd.service
sudo systemctl disable pamac-cleancache.timer
sudo systemctl disable pamac-mirrorlist.timer
sudo systemctl disable ufw.service
sudo systemctl disable cups.service
sudo systemctl mask systemd-rfkill.service  # suggested by tlp-stat
sudo systemctl mask systemd-rfkill.socket   # suggested by tlp-stat


echo -e "\n\e[1;33m          ++++++++++ TouchPad Configuration ++++++++++ \e[1;00m"
sudo mkdir -p /etc/X11/xorg.conf.d && sudo tee <<'EOF' /etc/X11/xorg.conf.d/90-touchpad.conf 1> /dev/null
Section "InputClass"
        Identifier "touchpad"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "Tapping" "on"
EndSection

EOF


echo -e "\n\e[1;33m          ++++++++++ XORG Intel COnfiguration ++++++++++ \e[1;00m"
sudo tee <<'EOF' /etc/X11/xorg.conf.d/20-intel.conf 1> /dev/null
Section "Device"
  Identifier "Intel Graphics"
  Driver "intel"
  Option "TearFree" "true"
EndSection

EOF

echo -e "\n\e[1;33m          ++++++++++ nano editor configuration ++++++++++ \e[1;00m"
if [ ! -e ~/.nanorc ]
then
  touch ~/.nanorc
fi
cp -r "./files/nanorc" ~/.nanorc
echo $'\u2714' "NANO Configured"

echo "\n\e[1;33m             ++++++++++ Terraform Configuration ++++++++++ \e[1;00m"
sudo cp ./files/terraform/* /usr/local/bin
echo $'\u2714' "All versions of terraform set to path"

echo -e "\n\e[1;33m          ++++++++++ IP tables ++++++++++ \e[1;00m"
sudo systemctl start iptables.service
sudo cp ./files/firewall.txt /etc/iptables/iptables.rules
sudo systemctl enable iptables.service
echo $'\u2714' "IP tables set and service enabled"

echo -e "\n\e[1;33m          ++++++++++ limit coredump in coredump.conf ++++++++++ \e[1;00m"
sudo sed -i -e 's/.*Proc.*/ProcessSizeMax=0/' -e 's/.*Stor.*/Storage=none/' /etc/systemd/coredump.conf

echo -e "\n\e[1;33m          ++++++++++ Ulimit coredump and add tmout ++++++++++ \e[1;00m"
if [ ! -e /etc/profile.d/custom.sh ]
then
  sudo touch /etc/profile.d/custom.sh 
fi
sudo cp -r "./files/custom_profile.txt" /etc/profile.d/custom.sh

echo -e "\n\e[1;33m         +++++++++++ Limit Journal size to 50MB ++++++++++ \e[1;00m"
if grep -q "#SystemMaxUse" /etc/systemd/journald.conf; then
  sudo sed -i 's/#SystemMaxUse.*/SystemMaxUse=50M/' /etc/systemd/journald.conf
  echo $'\u2605' "Journal size limited to 50 MB"
fi

echo -e "\n\e[1;33m          ++++++++++ Hard limit for coredump ++++++++++ \e[1;00m"
if [ ! -e /etc/security/limits.d/50-coredump.conf ]
then
  sudo touch /etc/security/limits.d/50-coredump.conf
fi
sudo cp -r "./files/hard_coredump.txt" /etc/security/limits.d/50-coredump.conf

echo -e "\n\e[1;33m          ++++++++++ Addding Banner File ++++++++++ \e[1;00m"
sudo cp "./files/issue" /etc/issue
cat /etc/issue

echo -e "\n\e[1;33m          ++++++++++ Hardening compilers by restricying access only to root ++++++++++ \e[1;00m"
if [ -e /usr/bin/gcc ]
then
  echo "Found GCC"
  sudo chmod o-rx /usr/bin/gcc
fi

if [ -e /usr/bin/as ]
then
  echo "Found AS"
  sudo chmod o-rx /usr/bin/as
fi

if [ -e /usr/bin/cc ]
then
  echo "Found CC"
  sudo chmod o-rx /usr/bin/cc
fi

if [ -e /usr/bin/g++ ]
then
  echo "Found G++"
  sudo chmod o-rx /usr/bin/g++
fi

echo -e "\n\e[1;33m          ++++++++++ Checking and Enabling FAILLOG_ENAB option in /etc/login.defs ++++++++++ \e[1;00m"
echo "TO DO"

echo -e "\n\e[1;33m          ++++++++++ Copy conky file ++++++++++ \e[1;00m"
if [ ! -e ~/.config/conky ] 
then 
  echo "Creating Conky Config folder"
  mkdir ~/.config/conky
else
  echo "Conky config folder Folder exist"
fi
echo "Copying Conky Configurations"
cp "./files/conky.conf" ~/.config/conky/conky.conf

echo -e "\n\e[1;33m          ++++++++++ Conky Autostart ++++++++++ \e[1;00m"
cp "./files/conky.desktop" ~/.config/autostart/conky.desktop

echo -e "\n\e[1;33m          ++++++++++ pacman config changes ++++++++++ \e[1;00m"
if grep -q "#Color" "/etc/pacman.conf"; then
  sudo sed -i 's/#Color/Color/' "/etc/pacman.conf"
  echo $'\u2714' "Color"
fi

if grep -q "#VerbosePkgLists" "/etc/pacman.conf"; then
  sudo sed -i 's/#VerbosePkgLists/VerbosePkgLists/' "/etc/pacman.conf"
  echo $'\u2714' "Get the version change details of packages"
fi

if grep -q "ILoveCandy" "/etc/pacman.conf"; then
  echo "Candy theme already present"
else
  sudo sed -i '/Misc/a ILoveCandy' "/etc/pacman.conf"
  echo $'\u2714' "ILoveCandy"
fi

if grep -q "#ParallelDownloads" "/etc/pacman.conf"; then
  sudo sed -i 's/#ParallelDownloads.*/ParallelDownloads = 5/' "/etc/pacman.conf"
  echo $'\u2714' "5 Parallel Downloads"
fi

echo -e "\n\e[1;33m          ++++++++++ pamac config changes ++++++++++ \e[1;00m"

if grep -q "RefreshPeriod" /etc/pamac.conf; then
  sudo sed -i 's/RefreshPeriod.*/RefreshPeriod = 0/' /etc/pamac.conf
  echo $'\u2714' "Refresh Period set to 0"
fi

if grep -q "#NoUpdateHideIcon" /etc/pamac.conf; then
  sudo sed -i 's/#NoUpdateHideIcon.*/NoUpdateHideIcon/' /etc/pamac.conf
  echo $'\u2714' "Hide icon if there is no update"
fi

if grep -q "#EnableAUR" /etc/pamac.conf; then
  sudo sed -i 's/#EnableAUR.*/EnableAUR/' /etc/pamac.conf
  echo $'\u2714' "Enabled AUR"
fi

if grep -q "KeepNumPackages" /etc/pamac.conf; then
  sudo sed -i 's/KeepNumPackages.*/KeepNumPackages = 5/' /etc/pamac.conf
  echo $'\u2714' "5 older packages are kept"
fi

echo -e "\n\e[1;33m          ++++++++++ XFCE Configurations ++++++++++ \e[1;00m"
xfconf-query -c xfce4-panel -p /panels/panel-0/position-locked -s false
echo -e "\e[1;32m >>> Mouse Settings changed \e[1;34m"
xfconf-query -c pointers -p /Synaptics_TM3127-001/Properties/libinput_Tapping_Enabled -s 1
xfconf-query -c pointers -p /Synaptics_TM3127-001/ReverseScrolling -s true
echo -e "\e[1;32m >>> Desktop icons removed \e[1;34m"
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home -n -t bool -s false
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -n -t bool -s false
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-trash -n -t bool -s false
# xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home -s false
# xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -s false
# xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-trash -s false
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-removable -s false
echo -e "\e[1;32m >>> Wallpaper Changed \e[1;34m"
sudo cp ./files/au.jpg /usr/share/backgrounds/wallpaper.jpg
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s "/usr/share/backgrounds/wallpaper.jpg"
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitoreDP1/workspace0/last-image -s "/usr/share/backgrounds/wallpaper.jpg"
echo -e "\e[1;32m >>> Theme Changed \e[1;34m"
xfconf-query -c xsettings -p /Net/ThemeName -s Matcha-dark-sea
xfconf-query -c xsettings -p /Net/IconThemeName -s Papirus-Dark-Maia
xfconf-query -c xsettings -p /Gtk/FontName -s "Cantarell 10"
echo -e "\e[1;32m >>> Window manager Changed \e[1;34m"
xfconf-query -c xfwm4 -p /general/move_opacity -s 50
xfconf-query -c xfwm4 -p /general/theme -s Matcha-dark-sea
xfconf-query -c xfwm4 -p /general/title_font -s "Cantarell Ultra-Bold 10"
xfconf-query -c xfwm4 -p /general/workspace_count -s 1
xfconf-query -c xfwm4 -p /general/show_dock_shadow -s false
echo -e "\e[1;32m >>> Panel settings Changed \e[1;34m"
xfconf-query -c xfce4-panel -p /panels/panel-0/position -s "p=6;x=683;y=13"
xfconf-query -c xfce4-panel -p /panels/panel-0/icon-size -n -t int -s 0
xfconf-query -c xfce4-panel -p /panels/panel-0/background-style -s 2
sudo cp ./files/transparent.png /usr/share/backgrounds/transparent.png
xfconf-query -c xfce4-panel -p /panels/panel-0/background-image -n -t string -s "/usr/share/backgrounds/transparent.png"
# xfconf-query -c xfce4-panel -p /panels/panel-0/background-image -s "/mnt/BC38214F38210A4A/DOWNLOADS/t4.png"
xfconf-query -c xfce4-panel -p /panels/panel-0/size -s 26
echo -e "\e[1;32m >>> Keyboard shortcuts changed \e[1;34m"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Primary><Alt>comma" -n -t string -s "systemctl reboot"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Primary><Alt>period" -n -t string -s "systemctl poweroff"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>d" -n -t string -s show_desktop_key
xfconf-query -c xfce4-panel -p /panels/panel-0/position-locked -s true

echo -e "\n\e[1;33m          ++++++++++ Change terminal settings ++++++++++ \e[1;00m"

if grep -q "MiscCursorBlinks" ~/.config/xfce4/terminal/terminalrc; then
  sed -i 's/MiscCursorBlink.*/MiscCursorBlinks=FALSE/' ~/.config/xfce4/terminal/terminalrc
  echo $'\u2714' "Cursor Blinking set to false"
else
  echo "MiscCursorBlinks=FALSE" >> ~/.config/xfce4/terminal/terminalrc
fi

if grep -q "MiscDefaultGeometry" ~/.config/xfce4/terminal/terminalrc; then
  sed -i 's/MiscDefaultGeo.*/MiscDefaultGeometry=102x30/' ~/.config/xfce4/terminal/terminalrc
  echo $'\u2714' "Default geometry set to 102x30"
else
  echo "MiscDefaultGeometry=102x30" >> ~/.config/xfce4/terminal/terminalrc
fi

if grep -q "MiscMenubarDefault" ~/.config/xfce4/terminal/terminalrc; then
  sed -i 's/MiscMenubarDef.*/MiscMenubarDefault=FALSE/' ~/.config/xfce4/terminal/terminalrc
  echo $'\u2714' "Default menubar set to false"
else
  echo "MiscMenubarDefault=FALSE" >> ~/.config/xfce4/terminal/terminalrc
fi

if grep -q "MiscCopyOnSelect" ~/.config/xfce4/terminal/terminalrc; then
  sed -i 's/MiscCopyOnSel.*/MiscCopyOnSelect=TRUE/' ~/.config/xfce4/terminal/terminalrc
  echo $'\u2714' "Copy on select sect to true"
else
  echo "MiscCopyOnSelect=TRUE" >> ~/.config/xfce4/terminal/terminalrc
fi

if grep -q "MiscSlimTabs" ~/.config/xfce4/terminal/terminalrc; then
  sed -i 's/MiscSlimTabs.*/MiscSlimTabs=TRUE/' ~/.config/xfce4/terminal/terminalrc
  echo $'\u2714' "Slim tabs set to true"
else
  echo "MiscSlimTabs=TRUE" >> ~/.config/xfce4/terminal/terminalrc
fi

if grep -q "ScrollingBar" ~/.config/xfce4/terminal/terminalrc; then
  sed -i 's/ScrollingBar.*/ScrollingBar=TERMINAL_SCROLLBAR_NONE/' ~/.config/xfce4/terminal/terminalrc
  echo $'\u2714' "Hide scrool bar"
else
  echo "ScrollingBar=TERMINAL_SCROLLBAR_NONE" >> ~/.config/xfce4/terminal/terminalrc
fi
#
#if grep -q "DropdownWidth" ~/.config/xfce4/terminal/terminalrc; then
#  sed -i 's/DropdownW.*/DropdownWidth=60/' ~/.config/xfce4/terminal/terminalrc
#  echo PASS
#else
#  echo "DropdownWidth=60" >> ~/.config/xfce4/terminal/terminalrc
#fi
#
#if grep -q "DropdownHeight" ~/.config/xfce4/terminal/terminalrc; then
#  sed -i 's/DropdownH.*/DropdownHeight=65/' ~/.config/xfce4/terminal/terminalrc
#  echo PASS
#else
#  echo "DropdownHeight=65" >> ~/.config/xfce4/terminal/terminalrc
#fi
#
#if grep -q "DropdownPositionVertical" ~/.config/xfce4/terminal/terminalrc; then
#  sed -i 's/DropdownPositionV.*/DropdownPositionVertical=50/' ~/.config/xfce4/terminal/terminalrc
#  echo PASS
#else
#  echo "DropdownPositionVertical=50" >> ~/.config/xfce4/terminal/terminalrc
#fi

if grep -q "DropdownAlwaysShowTabs" ~/.config/xfce4/terminal/terminalrc; then
  sed -i 's/DropdownAlwaysShowTabs.*/DropdownAlwaysShowTabs=FALSE/' ~/.config/xfce4/terminal/terminalrc
  echo PASS
else
  echo "DropdownAlwaysShowTabs=FALSE" >> ~/.config/xfce4/terminal/terminalrc
fi

if grep -q "DropdownShowBorders" ~/.config/xfce4/terminal/terminalrc; then
  sed -i 's/DropdownShowBorders.*/DropdownShowBorders=TRUE/' ~/.config/xfce4/terminal/terminalrc
  echo PASS
else
  echo "DropdownShowBorders=TRUE" >> ~/.config/xfce4/terminal/terminalrc
fi

if grep -q "FontName" ~/.config/xfce4/terminal/terminalrc; then
  sed -i 's/FontName.*/FontName=Monospace 10/' ~/.config/xfce4/terminal/terminalrc
  echo PASS
else
  echo "FontName=Monospace 10" >> ~/.config/xfce4/terminal/terminalrc
fi

echo "Reboot the System"
