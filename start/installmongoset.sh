#!/bin/bash

#installmongoset.sh shard 1 

source set.sh

key=""

local_ip=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v 58.49 |grep -v inet6|awk '{print $2}'|tr -d "addr:"`


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


if [[ "$reinstall" == "reinstall" ]]; then
    echo "kill all mongod"
    killall mongod
    killall mongos
    rm -rf $dir/db
    rm -rf $dir/logs
fi


mkdir -p $dir/logs
mkdir -p $dir/db

echo $key
echo $dir
echo $CONFIGDB
echo $conf
echo $tmpconf


cp $conf $tmpconf

dir2=${dir//\//\\\/}
sed -i "s/_path_/$dir2/g" $tmpconf
sed -i "s/27017/$port/g" $tmpconf
sed -i "s/_repl_Set_Name_/${replicationName}/g" $tmpconf

cat $tmpconf


if [[ "$mode" == "mongos" ]]; then
    echo 'start mongos'
    mongos --configdb $CONFIGDB -f $tmpconf $key --fork
else
    echo 'start shard/config'

    mongod -f $tmpconf $key --inMemorySizeGB 16 --fork
fi

