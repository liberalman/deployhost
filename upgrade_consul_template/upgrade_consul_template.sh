#!/bin/bash

# tar cvzf upgrade_consul_template.v0.19.0.tar.gz upgrade_consul_template/

NEW_VERSION=v0.19.0
OLD_VERSION=v0.15.0
CONSUL_TEMPLATE_DIR=/data/app/greatwall_consul_template
NGINX_CFG_DIR=/etc/nginx
TMP_DIR=/tmp/upgrade_consul_template
CONSUL_TEMPLATE=$CONSUL_TEMPLATE_DIR/bin/consul-template
CONSUL_TEMPLATE_NEW="./consul-template.$NEW_VERSION"
CONSUL_TEMPLATE_BACKUPED="$TMP_DIR/consul-template.$OLD_VERSION"

function check_env()
{
    if [ ! -d $TMP_DIR ]; then
        mkdir $TMP_DIR
    fi
    
    `$CONSUL_TEMPLATE -v > $TMP_DIR/version 2>&1`
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

function restore()
{
    echo "restore..."
    cp $CONSUL_TEMPLATE_NEW $CONSUL_TEMPLATE
    $CONSUL_TEMPLATE \
        -config=$CONSUL_TEMPLATE_DIR/conf/consul-template.conf \
        -template "$CONSUL_TEMPLATE_DIR/conf/nginx-services.conf.ctmpl:$TMP_DIR/services-new.conf" -once > $TMP_DIR/consul-template.log
    diff $NGINX_CFG_DIR/conf.d/services.conf $TMP_DIR/services-new.conf > $TMP_DIR/diff
    if [ -s "$TMP_DIR/diff" ]; then
        echo "$TMP_DIR/diff is not empty. $NGINX_CFG_DIR/conf.d/services.conf is not equal $TMP_DIR/services-new.conf"
        exit -2
    else
        service consul_template start
        echo "upgrade success!"
    fi
}

function rollback()
{
    echo "rollback..."
    service consul_template stop
    cp $TMP_DIR/services.conf $NGINX_CFG_DIR/conf.d/
    cp $CONSUL_TEMPLATE_BACKUPED $CONSUL_TEMPLATE
    service consul_template start
}

function backup()
{
    check_env

    # 1. Backup consul-temple to prevent rollback.
    cp $CONSUL_TEMPLATE $CONSUL_TEMPLATE_BACKUPED

    # 2. Stop consul_template service
    service consul_template stop

    # 3. Backup nginx.conf to prevent rollback.
    cp $NGINX_CFG_DIR/conf.d/services.conf $TMP_DIR
    
    #ls $TMP_DIR
}

function Usage()
{
    echo "Usage: $0 backup|restore|clean"
    exit -1
}

case $1 in
    "backup")
        backup;
        ;;
    "restore")
        restore;
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

