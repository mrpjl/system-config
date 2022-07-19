#!/bin/bash

#####################################################
#
#   Main file
#
#####################################################

unalias cp
chmod 755 files/*

##################################################################
#######################TEMPLATE###################################
# echo -e "\n\e[1;33m          ++++++++++  ++++++++++ \e[1;34m"
# echo $'\u0c93'"O"
##################################################################

# Function to confirm before executing any command
function confirm() {
    read -p "Confirm to continue [y/N]" yn
    if [[ $yn == 'y' ]]
    then
        return 0
    else
        return 1
    fi
}

echo -e "\n\e[1;33m          ++++++++++ Update Package DB ++++++++++ \e[1;34m"
sudo pacman -Sy
echo $'\u2714' "Package DataBase Updated"

echo -e "\n\e[1;33m          ++++++++++ Install needed packages ++++++++++ \e[1;00m"
sudo pacman -Su --needed $(cat ./files/packages | fzf -m)

############################# SYSTEM HARDENING #############################

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
sudo systemctl mask systemd-rfkill.service  # suggested by tlp-stat
sudo systemctl mask systemd-rfkill.socket   # suggested by tlp-stat

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

echo -e "\n\e[1;33m          ++++++++++ Hard limit for coredump ++++++++++ \e[1;00m"
if [ ! -e /etc/security/limits.d/50-coredump.conf ]
then
  sudo touch /etc/security/limits.d/50-coredump.conf
fi
sudo cp -r "./files/hard_coredump.txt" /etc/security/limits.d/50-coredump.conf

echo -e "\n\e[1;33m         +++++++++++ Limit Journal size to 50MB ++++++++++ \e[1;00m"
if grep -q "#SystemMaxUse" /etc/systemd/journald.conf; then
  sudo sed -i 's/#SystemMaxUse.*/SystemMaxUse=50M/' /etc/systemd/journald.conf
  echo $'\u2605' "Journal size limited to 50 MB"
fi

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

############################# SYSTEM CONFIGURATION & RICING #############################

echo -e "\n\e[1;33m          ++++++++++ TouchPad Configuration ++++++++++ \e[1;00m"
sudo mkdir -p /etc/X11/xorg.conf.d && sudo tee <<'EOF' /etc/X11/xorg.conf.d/90-touchpad.conf 1> /dev/null
Section "InputClass"
        Identifier "touchpad"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "Tapping" "on"
EndSection

EOF

echo -e "\n\e[1;33m          ++++++++++ XORG Intel Configuration ++++++++++ \e[1;00m"
sudo tee <<'EOF' /etc/X11/xorg.conf.d/20-intel.conf 1> /dev/null
Section "Device"
  Identifier "Intel Graphics"
  Driver "intel"
  Option "TearFree" "true"
EndSection

EOF

echo -e "\n\e[1;33m          ++++++++++ Application Configuration ++++++++++ \e[1;34m"
xdg-mime default org.pwmt.zathura.desktop application/pdf
echo $'\u2714' "Set Zathura as default app for PDF"

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

if [[ ! -d /etc/pacman.d/hooks ]]; then
  sudo mkdir /etc/pacman.d/hooks /etc/pacman.d/hooks.bin
  echo $'\u2714' "Created PACMAN hooks folder"
fi
sudo cp ./files/pacman-clean.hook /etc/pacman.d/hooks/
sudo cp ./files/pacman-clean /etc/pacman.d/hooks.bin/


