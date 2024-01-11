#!/usr/bin/env bash
COLOR="$1"
if [ -n "$COLOR" ]; then
	
# SEE: https://wiki.archlinux.org/title/GNOME/Tips_and_tricks#Use_custom_colours_and_gradients_for_desktop_background
	echo "Setting color to $COLOR"
	gsettings set org.gnome.desktop.background primary-color "$COLOR"
	gsettings set org.gnome.desktop.background secondary-color "$COLOR"
	gsettings set org.gnome.desktop.background color-shading-type "solid"
else
	echo "$0 COLOR:hex"
fi
# EOF
