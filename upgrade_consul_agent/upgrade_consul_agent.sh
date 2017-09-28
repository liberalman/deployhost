#!/bin/bash

# tar cvzf upgrade_consul_agent.v0.9.3.tar.gz upgrade_consul_agent/

NEW_VERSION=v0.9.3
OLD_VERSION=v0.6.4
CONSUL_AGENT_DIR=/data/app/greatwall_consul_agent
TMP_DIR="/tmp/upgrade_consul_agent"
CONSUL_AGENT="$CONSUL_AGENT_DIR/bin/consul"
CONSUL_AGENT_NEW="./consul.$NEW_VERSION"
CONSUL_AGENT_BACKUPED="$TMP_DIR/consul.$OLD_VERSION"

function check_env()
{
    if [ ! -d $TMP_DIR ]; then
        mkdir $TMP_DIR
    fi

    `$CONSUL_AGENT -v > $TMP_DIR/version 2>&1`
    var=`cat $TMP_DIR/version` 
    regex="$NEW_VERSION"
    if [[ $var =~ $regex ]]; then
        # match
        echo "current version is ${regex}, no need upgrade!"
        exit
    fi
    
    #var=`jq --version > /dev/null 2>&1`
    #if [ $? -ne 0 ];then
    #    echo "jq not install, please install it."
    #    exit -1
    #fi
}

function clean()
{
    rm -rf $TMP_DIR
}

function rollback()
{
    echo "rollback..."
    service consul_agent stop
    cp $CONSUL_AGENT_BACKUPED $CONSUL_AGENT
    rm -rf $CONSUL_AGENT_DIR/data/*
    service consul_agent start
}

function upgrade()
{
    check_env

    # 1. Backup consul agent.
    cp $CONSUL_AGENT $CONSUL_AGENT_BACKUPED

    # 2. Stop consul_agent service
    if [ ! -f "/lib/systemd/system/consul_agent.service" ]; then
        $CONSUL_AGENT leave
        pushd $CONSUL_AGENT_DIR/bin
            ./stop.sh
        popd
    else
        service consul_agent stop
    fi

    # 3. Replace consul with new version.
    cp $CONSUL_AGENT_NEW $CONSUL_AGENT
    
    rm -rf $CONSUL_AGENT_DIR/data/*

    # 4. Start consul_agent
    if [ ! -f "/lib/systemd/system/consul_agent.service" ]; then
        pushd $CONSUL_AGENT_DIR/bin
            ./start.sh
        popd
    else
        service consul_agent start
    fi
}

function Usage()
{
    echo "Usage: $0 upgrade|rollback|clean"
    exit -1
}

case $1 in
    "upgrade")
        upgrade;
        ;;
    "rollback")
        rollback;
        ;;
    "clean")
        clean;
        ;;
    *)
        Usage
esac

