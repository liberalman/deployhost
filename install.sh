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
        git config --global user.email "zscchina@163.com"
        git config --global user.name "liberalman"
        git config --global push.default simple
        cd $DEPLOYHOST
    fi
}

function check_OS()
{
    #ubuntu=`uname -a|grep Ubuntu`
    #if [ "$ubuntu" != "" ];then
    if [ "$OS" == "ubuntu" ];then
        CMD="apt-get"
        CMD_PKG="dpkg --get-selections | grep "
        aliyun=`cat /etc/apt/sources.list | grep "mirrors.aliyun.com"`
        if [ "$aliyun" == "" ];then
            cat ./ubuntu/sources.list >> /etc/apt/sources.list
            apt-get update
        fi
    fi
}

function set_hostname()
{
    hostname=$1
    if [ "" != "$hostname" ];then
        echo $hostname > /etc/hostname
        sed -i "s/127.0.1.1.*/127.0.1.1        ${hostname}/g" /etc/hosts
    fi
    cat /etc/hostname
    echo -e "\n"
    cat /etc/hosts
    #echo -e "\n192.168.56.101  host-1\n192.168.56.102  host-2\n192.168.56.103  host-3" >> /etc/hosts
}

function install_softwares()
{
    softwares=("vim" "git" "cmake" "python-devel" "jq" "openssh-server" "docker" "python-setuptools" "telnet" "python-pip" "curl" "gcc" "zip" "unzip" "lrzsz" "expect")
    for soft in ${softwares[*]}
    do
        #exist=`${CMD_PKG} ${soft}`
        #if [ "" = "$exist" ]; then
            # $exist is empty
            $CMD install $soft -y
        #fi
    done
    if [ "$OS" == "ubuntu" ]; then
        apt-get install openjdk-8-jdk -y
        service ssh start
        echo "service ssh start" >> /etc/rc.local
        # vim /etc/ssh/sshd_config
        # set "PermitRootLogin yes"
    else
        yum install java-1.8.0-openjdk -y
    fi
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


function init_computer()
{
    if [ "$1" == "ubuntu" ]; then
        OS="ubuntu";
    elif [ "$1" == "centos" ]; then
        OS="centos"
    else
        echo "init must be ubuntu or centos"
        exit -1
    fi
    check_OS
    install_softwares
    check_env
    vim
    success
}

function restart_network()
{
   ifconfig enp0s3 down
   ifconfig enp0s8 down

   ifconfig enp0s3 up
   ifconfig enp0s8 up
}

function success()
{
    echo -e "\033[32m"
    b=`echo -e "\033[42;32m[]\033[0m  "`
    echo  Installing........
    echo     --------------------------------------------------------------
    for ((i=0;$i<=60;i+=2))
    do
          printf $b
          sleep 0.1
          b=`echo -e "\033[42;32m[]\033[0m  "`$b
    done
    echo -e "\033[32m"
    echo     --------------------------------------------------------------
    echo "Complete!"
    echo -e "\033[0m"
}

function Usage()
{
    echo -e "$0 [-ahir] string"
    echo -e "        -a|--hostname <hostname>.      set hostname and terminal name."
    echo -e "        -h|--help."
    echo -e "        -i|--initial <ubuntu|centos>.  set up softwares and configure your vim,openssh... when you get a new computer."
    echo -e "        -r|--renetwork.                restart network, for vBox to connect outer line."
}

if [ $# -lt 1 ]; then
    Usage
    exit -1
fi

TEMP=`getopt -o a:hi:rc:: --long hostname,help,initial,renetwork:,c-long:: \
    -n 'example.bash' -- "$@"`
if [ $? != 0 ]; then
    echo "Terminating..." >&2 ;
    exit 1 ;
fi
# Note the quotes around `$TEMP': they are essential!
# set 会重新排列参数的顺序，也就是改变$1,$2...$n的值，这些值在getopt中重新排列过了
eval set -- "$TEMP"
# 经过getopt的处理，下面处理具体选项。
while true ; do
    case "$1" in
        -a|--hostname)
            set_hostname $2
            shift 2 ;;
        -c|--c-long)
                # c has an optional argument. As we are in quoted mode,
                # an empty parameter will be generated if its optional
                # argument is not found.
                case "$2" in
                        "") echo "Option c, no argument"; shift 2 ;;
                        *) echo "Option c, argument \`$2'" ; shift 2 ;;
                esac ;;
        -h|--help)
            Usage
            shift ;;
        -i|--initial)
            init_computer $2
            shift 2 ;;
        -r|--renetwork)
            restart_network
            shift ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

