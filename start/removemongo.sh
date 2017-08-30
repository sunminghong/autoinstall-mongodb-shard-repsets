#!/bin/bash

#installmongoset.sh shard 1 

source set.sh

ps aux | grep mongo
echo "kill all mongod"

killall mongod

rm -rf ../config
rm -rf ../shard*
rm -rf ../mongos

#rm -rf ../conf
#rm -rf ../start
#rm -rf ../*

ps aux | grep mongo



