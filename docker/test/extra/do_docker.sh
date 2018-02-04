#!/bin/bash -e

function do_Shrink_Image(){
    echo
    echo '-- Cleaning image --'
    PATH=$PATH:~/.local/bin
    jhbuild clean || true
    rm -rf ~/.config/jhbuildrc ~/.jhbuildrc ~/checkout
    rm -rf ~/jhbuild/checkout
    rm -rf ~/jhbuild/install/lib/libjs_static.ajs

    if [[ $BASE == "ubuntu" ]]; then
        apt-get -y -qq remove --purge apt-file

        apt-get -y clean
        rm -rf /var/lib/apt/lists/*

    elif [[ $BASE == "fedora" ]]; then
        dnf -y clean all
    fi

    echo '-- Done --'
}

if [[ $1 == "BUILD_MOZ" ]]; then
    do_Install_Base_Dependencies
    do_Set_Env

    do_Show_Info
    do_Patch_JHBuild
    do_Build_JHBuild RESET
    do_Build_Mozilla
    do_Save_Files

    if [[ $2 == "SHRINK" ]]; then
        do_Shrink_Image
    fi

elif [[ $1 == "GET_FILES" ]]; then
    do_Set_Env
    do_Get_Files

    if [[ $2 == "DOCKER" ]]; then
        do_Install_Base_Dependencies
        do_Install_Dependencies

        if [[ $DEV == "devel" ]]; then
            do_Install_Extras
        fi

        # Build JHBuild to create a docker image ready to go
        do_Patch_JHBuild
        do_Build_JHBuild
        jhbuild build m4-common

        do_Shrink_Image
    fi
fi