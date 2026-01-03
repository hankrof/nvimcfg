#!/bin/bash

INSTALL_PATH=~/.config/nvim
MODULE_PATH=~/.local/share/nvim/lazy
MODULE_LINK=$INSTALL_PATH/modules

# arg1 - package name to be checked
function package_exists {
    which $1 > /dev/null 2>&1
    if [ $? == 0 ]; then
        return 1
    else
        return 0
    fi
}

# arg1 - package name to be installed
# arg2 - package name used in pacman
# arg3 - package name used in apt
function install_package {
    pkgname=$1
    pacman_pkgname=$2
    apt_pkgname=$3
    if [ -z "$pacman_pkgname" ]; then
        pacman_pkgname=$pkgname
    fi
    if [ -z "$apt_pkgname" ]; then
        apt_pkgname=$pkgname
    fi
    package_exists $pkgname
    existed=$?
    if [ "$existed" == "1" ]; then
        echo $pkgname "is installed"
    fi
    if [ "$existed" == "0" ]; then
        echo $pkgname "not detected, try installing!"
        package_exists pacman
        if [ "$?" == "1" ]; then
            echo "Detected pacman package manager!"
            sudo pacman -Syuu $pacman_pkgname --noconfirm
        fi
        package_exists apt
        if [ "$?" == "1" ]; then
            echo "Detected apt package manager!"
            sudo apt install $apt_pkgname
        fi
        package_exists $pkgname
        if [ "$?" == "0" ]; then
            echo $pkgname "is still not installed"
            echo "stop ..."
            exit 1
        fi
    fi
}

if [ $PWD == $INSTALL_PATH ]; then
    echo "Unable to install when workdir is install path [$INSTALL_PATH]"
    exit 1
fi

echo "Installing nvim ..."
if  [ -d $INSTALL_PATH ]; then
    echo "Found installed nvim configuration files"
    echo -n "Do you want to clean them before installing?(Y/n)"
    read choose
fi

if [ ${#choose} == 0 ]; then
    choose="Y"
fi

if [ $choose == "Y" ] || [ $choose == "y" ] || [ $choose == "yes" ]; then
    echo -n "Removing vim configuration files ...";
    rm -f coc-settings.json
    rm -f lazy-lock.json
    rm -f package-lock.json
    rm -f $INSTALL_PATH
    rm -f $MODULE_LINK
    rm -rf $MODULE_PATH
    sync
    echo "OK"
fi

if [ ! -d ~/Sources ]; then
    mkdir -p ~/Sources
fi

install_package node nodejs node
install_package npm
install_package yarn
install_package cmake
install_package ctags
install_package git
install_package clang clang clangd

package_exists bear
if [ "$?" == "0" ]; then
    echo "Bear not detected, try installing!"
    git clone https://github.com/rizsotto/Bear.git ~/Sources/Bear
    cd ~/Sources/Bear
    cmake .
    make all check
    sudo make install
    cd -
    echo "Done!"
fi

ln -sf $PWD $INSTALL_PATH
ln -sf $MODULE_PATH $MODULE_LINK
nvim --headless "+Lazy! sync" +qa
echo "Done!"

