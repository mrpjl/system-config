#!/bin/bash

#######################################################
#                                                     #
#  Script to Fetch all the config files to one place  #
#                                                     #
#######################################################

# Copy i3 Cnfig file
cp -r ~/.config/i3 ./files/

# Copy the Scripts
cp -r ~/.config/scripts ./files/

# Copy BAshrc file
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
cp ~/.config/qutebrowser/quickmarks ./files/qutebrowser/
cp ~/.config/qutebrowser/bookmarks/urls ./files/qutebrowser/

