#!/bin/bash

# Install softwares in a new machine

#DEPLOYHOST=~/deployhost
#DEPLOYHOST=`pwd`/deployhost
DEPLOYHOST=`pwd`

if [ ! -d $DEPLOYHOST ]; then
    git clone https://github.com/liberalman/deployhost.git $DEPLOYHOST
fi

function install_softwares()
{
    softwares=("git" "cmake" "python-devel" )
    for soft in ${softwares[*]}
    do
        echo $soft
        exist=`rpm -qa ${soft}`
        echo $exist
        if [ "" = "$exist" ]; then
            # $exist is empty
            yum install $soft -y
        fi
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


vim

