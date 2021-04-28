# Do we have appenv?
if [ ! -e "$HOME/.local/bin/appenv.bash" ]; then
    curl https://raw.githubusercontent.com/sebastien/appenv/master/install.sh | bash
fi

