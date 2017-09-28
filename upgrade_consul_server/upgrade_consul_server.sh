#!/bin/bash

# tar cvzf upgrade_consul_server.v0.9.3.tar.gz upgrade_consul_server/

NEW_VERSION=v0.9.3
OLD_VERSION=v0.6.4
CONSUL_SERVER_DIR=/usr/local/bin
TMP_DIR=/tmp/upgrade_consul_server
CONSUL_SERVER=$CONSUL_SERVER_DIR/consul
CONSUL_SERVER_NEW="./consul.$NEW_VERSION"
CONSUL_SERVER_BACKUPED="$TMP_DIR/consul.$OLD_VERSION"

function check_env()
{
    if [ ! -d $TMP_DIR ]; then
        mkdir $TMP_DIR
    fi
                            
    `$CONSUL_SERVER -v > $TMP_DIR/version 2>&1`
    var=`cat $TMP_DIR/version` 
    regex="$NEW_VERSION"
    if [[ $var =~ $regex ]]; then
        # match
        echo "current version is ${regex}, no need upgrade!"
        exit
    fi
}

function clean()
{
    rm -rf $TMP_DIR
}

function rollback()
{
    echo "rollback..."
    service consul stop
    cp $CONSUL_SERVER_BACKUPED $CONSUL_SERVER
    rm -rf /var/consul/*
    service consul start
}

function upgrade()
{
    check_env

    # 1. Backup consul to prevent rollback.
    cp $CONSUL_SERVER $CONSUL_SERVER_BACKUPED

    # 2. Stop consul service
    $CONSUL_SERVER leave
    service consul stop

    #ls $TMP_DIR
    
    # 1. Backup consul to prevent rollback.
    cp $CONSUL_SERVER_NEW $CONSUL_SERVER

    rm -rf /var/consul/*
    
    service consul start
}

function Usage()
{
    echo "Usage: $0 upgrade|restore|clean"
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

