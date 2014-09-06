#!/bin/bash

#Colors
RCol='\e[0m' #Reset
Red='\e[0;31m'
Gre='\e[0;32m'
Yel='\e[1;33m'
Pur='\e[1;35m'

fn_checkversion(){
    if [ $1 == "Ubuntu" ]; then
        if [[ $(lsb_release -r | tr -cd [:digit:]) == 14* ]]; then
            version=14
            echo -e "$Gre OK:$Yel Ubuntu$Gre version found:$RCol 14\n"
        elif [[ $(lsb_release -r | tr -cd [:digit:]) == 13* ]]; then
            version=13
            echo -e "$Gre OK:$Yel Ubuntu$Gre version found:$RCol 13\n"
        elif [[ $(lsb_release -r | tr -cd [:digit:]) == 12* ]]; then
            version=12
            echo -e "$Gre OK:$Yel Ubuntu$Gre version found:$RCol 12\n"
        else
            echo -e "$Red FAIL: Unsupported Ubuntu version detected."
            echo -e "If you believe this is in error, please report your distro"
            echo -e "information as an issue to the LGSM GitHub repo."
            echo -e "$RCol";exit 1
        fi
    elif [ $1 == "Debian" ]; then
        if [[ $(lsb_release -r | tr -cd [:digit:]) == 7* ]]; then
            version=7
            echo -e "$Gre OK:$Red Debian$Gre version found:$RCol 7\n"
        elif [[ $(lsb_release -r | tr -cd [:digit:]) == 6* ]]; then
            version=6
            echo -e "$Gre OK:$Red Debian$Gre version found:$RCol 6\n"
        else
            echo -e "$Red FAIL: Unsupported Debian version detected."
            echo -e "If you believe this is in error, please report your distro"
            echo -e "information as an issue to the LGSM GitHub repo."
            echo -e "$RCol";exit 1
        fi
    elif [ $1 == "CentOS" ]; then
        if [[ $(cat /etc/centos-release | tr -cd [:digit:]) == 7* ]]; then
            version=7
            echo -e "$Gre OK:$Pur CentOS$Gre version found:$RCol 7\n"
        elif [[ $(cat /etc/centos-release | tr -cd [:digit:]) == 6* ]]; then
            version=6
            echo -e "$Gre OK:$Pur CentOS$Gre version found:$RCol 6\n"
        else
            echo -e "$Red FAIL: Unsupported CentOS version detected."
            echo -e "If you believe this is in error, please report your distro"
            echo -e "information as an issue to the LGSM GitHub repo."
            echo -e "$RCol";exit 1
        fi
    fi
}

fn_checkarch(){
    command -v arch > /dev/null
    if [ $? -eq 0 ]; then
        if [[ $(arch) == x86_64 ]]; then
            arc=64
            echo -e "$Gre OK: Architecture is$RCol 64-bit\n"
        elif [[ $(arch) == i* ]]; then
            arc=32
            echo -e "$Gre OK: Architecture is$RCol 32-bit"
            echo -e "   (If you can, consider updating to 64-bit.)\n"
        else
            echo -e "$Red FAIL: Unknown kernel version $(arch) detected."
            echo -e "If you believe this is in error, please report your distro"
            echo -e "information as an issue to the LGSM GitHub repo."
            echo -e "$RCol";exit 1
        fi
    else
        echo -e "$Red ERROR: Couldn't detect arch, exiting."
        echo -e "$RCol";exit 1
    fi
}

fn_nomorereleases(){
    echo -n "\n$Red FAIL: No more releases to check. Current distro unsupported."
    echo -e "$RCol";exit 1
}

fn_checkrelease_centos(){
    cat /etc/centos-release > /dev/null
    if [ $? -eq 0 ]; then
        echo -e "$Gre OK:$Pur CentOS distro detected.$RCol\n"
        release="CentOS"
    else
        echo -e "$RCol FAIL: Release is NOT$Pur CentOS$RCol. Checking next release...$RCol"
        fn_nomorereleases 
    fi
}

fn_checkrelease(){
    command -v lsb_release > /dev/null
    if [ $? -eq 0 ]; then
        echo -e "$Gre OK: Release is$Red Debian$Gre based. Checking flavor..."
        if [ $(lsb_release -si) == "Debian" ]; then
            echo -e "$Gre OK:$Red Debian$Gre distro detected.$RCol\n"
            release="Debian"
        elif [ $(lsb_release -si) == "Ubuntu" ]; then
            echo -e "$Gre OK:$Yel Ubuntu$Gre distro detected.$RCol\n"
            release="Ubuntu"
        elif [[ $(lsb_release) == *buntu ]]; then
            echo -e "$Gre OK:$Red Unknown$Yel Ubuntu$Gre distro detected.$RCol\n"
            release="Ubuntu"
        else
            echo -e "$Red FAIL: Unsupported Debian distro detected."
            echo -e "If you believe this is in error, please report your distro"
            echo -e "information as an issue to the LGSM GitHub repo."
            echo -e "$RCol";exit 1
        fi
    else
        echo "FAIL: Release is NOT Debian based. Checking next release..."
        fn_checkrelease_centos
    fi
}

fn_header(){
    echo -e ""
    echo -e "Linux Game Server Manager"
    echo -e "Compatibility Check Script"
    echo -e "Version: 050914"
    echo -e ""
    echo -e "LGSM coded by: Daniel Gibbs"
    echo -e "CCS coded by: Scarsz"
    echo -e "============================"
    echo -e ""
}

fn_header
echo -e "Checking distro release..."
fn_checkrelease
echo -e "Checking distro version..."
fn_checkversion $release
echo -e "Checking kernel architecture..."
fn_checkarch
echo -e "$Gre"
echo -e "Distro/kernel dependencies have been met."
echo -e "You are able to use LGSM scripts on this machine."
echo -e "\n"
echo -e "$RCol";exit 0
