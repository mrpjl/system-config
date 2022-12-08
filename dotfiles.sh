#!/bin/bash

#######################################################
#                                                     #
#  Script to Fetch all the config files to one place  #
#                                                     #
#######################################################

# List all the installed packages for my reference
pacman -Qq > ./files/installed_packages

# Copy i3 Config file
cp -r ~/.config/i3 ./files/

# Copy the Scripts
cp -r ~/.config/scripts ./files/

# Copy Bashrc file
cp ~/.bashrc ./files/

# Copy GRUVBOX ColorScheme for VIM
git clone https://github.com/morhetz/gruvbox.git  /tmp/gruvbox
cp /tmp/gruvbox/colors/* ./files/
rm -rf /tmp/gruvbox/

# Copy Dunst Configuration
cp -r ~/.config/dunst ./files/

# Copy PICOM config file
cp -r ~/.config/picom ./files/

# Copy Terraform Versions
#TBD

# Copy .Xresource file
cp ~/.Xresources ./files/

# Copy Qutebrowser config.py file.
cp ~/.config/qutebrowser/config.py ./files/qutebrowser/
# cp ~/.config/qutebrowser/quickmarks ./files/qutebrowser/
# cp ~/.config/qutebrowser/bookmarks/urls ./files/qutebrowser/

# Copy the dircolors file
cp ~/.config/dircolors/.dircolors ./files/

# Copy the TMUX configuration file(s)
cp -r ~/.config/tmux ./files/
