# Do we have appenv?
APPENV_DEV_PATH=$HOME/Workspace/Community/appenv
if [ ! -e "$APPENV_DEV_PATH/bin/appenv.bash" ] &&  [ ! -e "$HOME/.local/bin/appenv.bash" ]; then
    curl https://raw.githubusercontent.com/sebastien/appenv/master/install.sh | bash
fi

# We load nix if we have it
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . $HOME/.nix-profile/etc/profile.d/nix.sh
fi

if [ -e "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
	 source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# EOF
