#!/usr/bin/bash
# This scripts installs Ansible using yum package management tool

is_installed () {

    if yum list installed "$@" >/dev/null 2>&1; then
        true
    else
        false
    fi
}

if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
fi

yum -y install epel-release
yum -y update
yum -y install ansible

echo "ansible ... installed"

echo "Installing Dependencies"

# WGET
if is_installed 'wget'; then
    echo "wget ... already installed"
else
    yum install wget -y
    echo "wget ... installed"
fi

# GIT
if is_installed 'git'; then
    echo "git ... already installed"
else
    yum install git -y
    echo "git ... installed"
fi
