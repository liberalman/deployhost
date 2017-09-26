#!/bin/bash

# Install softwares in a new machine

DEPLOYHOST=~/deployhost
OS=centos
CMD="yum"
CMD_PKG="rpm -qa"

function check_env()
{
    if [ ! -d $DEPLOYHOST ]; then
        git clone https://github.com/liberalman/deployhost.git $DEPLOYHOST
        cd $DEPLOYHOST
    fi
}

function check_OS()
{
    ubuntu=`uname -a|grep Ubuntu`
    if [ "$ubuntu" != "" ];then
        OS=ubuntu
        if [ "$OS" == "ubuntu" ];then
            CMD="apt-get"
            CMD_PKG="dpkg --get-selections | grep "
            aliyun=`cat /etc/apt/sources.list | grep "mirrors.aliyun.com"`
            if [ "$aliyun" == "" ];then
                cat ./ubuntu/sources.list >> /etc/apt/sources.list
                apt-get update
            fi
        fi
    fi
}

function install_softwares()
{
    softwares=("vim" "git" "cmake" "python-devel" "jq" "openssh-server")
    for soft in ${softwares[*]}
    do
        #exist=`${CMD_PKG} ${soft}`
        #if [ "" = "$exist" ]; then
            # $exist is empty
            $CMD install $soft -y
        #fi
    done
}

function vim()
{
    if [ ! -d ~/.vim ]; then
        mkdir -p ~/.vim
    fi
    if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
        git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
        echo "clone Vundle success"
    fi
    #if [ ! -d ~/.vim/bundle/YouCompleteMe ]; then
    #    git clone https://github.com/Valloric/YouCompleteMe.git ~/.vim/bundle/YouCompleteMe
    #    pushd ~/.vim/bundle/YouCompleteMe
    #        git submodule update --init --recursive
    #        ./install.py --clang-completer
    #    popd
    #    echo "clone YouCompleteMe success"
    #fi
    if [ ! -f ~/.vimrc ]; then
        # file not exist
        ln -s $DEPLOYHOST/.vimrc ~/.vimrc
        echo "link ~/.vimrc success"
    fi
}

check_OS
install_softwares
check_env
vim
