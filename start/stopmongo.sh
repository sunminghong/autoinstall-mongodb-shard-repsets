#!/bin/bash

#installmongoset.sh shard 1 

source set.sh

echo "kill all mongod"
killall mongod

killall mongos
