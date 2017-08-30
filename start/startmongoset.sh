#!/bin/bash

source set.sh

key=""

if [ -f "/etc/mongo/keyfile" ]; then
    key=" --keyFile /etc/mongo/keyfile"
#else
    #openssl rand -base64 755 > ../conf/keyfile
    #chmod 400 ../conf/keyfile
fi

mode=$1
instance=$2
reinstall=$3

conffile="mongo.conf"

if [[ "$mode" == "config" ]]; then
    conffile="config_sample.conf"
    tmpfile="config.conf"
    replicationName="config"
    dir=$configdir
    port=$config_port
fi

if [[ "$mode" == "shard" ]]; then
    conffile="shard_sample.conf"
    tmpfile=shard$instance.conf
    replicationName=shard$instance
    dir=$sharddir$instance
    eval port=\$shard${instance}_port
fi

if [[ "$mode" == "mongos" ]]; then
    conffile="mongos_sample.conf"
    tmpfile="mongos.conf"
    replicationName="mongos"
    dir=$mongosdir
    port=$mongos_port
fi


#cat /etc/mongo/$conffile

if [ -f "/data/mongo/conf/$conffile" ]; then
    conf="/data/mongo/conf/$conffile"
    tmpconf="$dir/$tmpfile"
fi


if [[ "$mode" == "mongos" ]]; then
    echo 'start mongos'
    echo "mongos --configdb $CONFIGDB -f $tmpconf $key --fork"
    mongos --configdb $CONFIGDB -f $tmpconf $key --fork
else
    echo 'start shard/config'

    mongod -f $tmpconf $key --inMemorySizeGB 16 --fork
fi

