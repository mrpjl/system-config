#!/bin/bash

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

echo -e "\n\e[1;33m Remove packages which are not Installed. \e[1;00m"
if confirm; then
    paccache -ruvk0
else
    echo "Skipped removing uninstalled packages..."
fi


echo -e "\n\e[1;33m Remove all old packages from Cache except the 2 latest versions. \e[1;00m"
if confirm; then
    paccache -rvk2
else
    echo "Skipped removing old packages..."
fi

# Retain only 50 MB of journalctl log
# journalctl --vacuum-time=50M

echo -e "\n\e[1;33m Remove cache files older than 30 days. \e[1;00m"
if confirm; then
    find ~/.cache/ -type f -atime +30 -delete
else
    echo "Skipped deleting old cache..."
fi

echo -e "\n\e[1;33m Unused packages. \e[1;00m"
pacman -Qdt

echo -e "\n\e[1;33m Remove unused packages. \e[1;00m"
if confirm; then
    sudo pacman -R $(pacman -Qdtq)
else
    echo "Skipped removing unused packages..."
fi
