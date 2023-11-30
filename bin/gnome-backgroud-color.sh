#!/usr/bin/env bash
COLOR="$1"
if [ -n "$COLOR" ]; then
echo "Setting color to $COLOR"
gsettings set org.gnome.desktop.background primary-color "$COLOR"
gsettings set org.gnome.desktop.background secondary-color "$COLOR"
gsettings set org.gnome.desktop.background color-shading-type "solid"
fi
# EOF
