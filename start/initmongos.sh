#!/bin/bash

source set.sh
#confjs="${mongosdir}/conf.js"
#mongo_cmd="docker exec -it ${mongosname} mongo "

mongos_host=127.0.0.1

echo "
db = connect('${mongos_host}:${mongos_port}/admin');
db.getSiblingDB('admin');

sh.addShard('shard1/${host1}:${shard1_port},${host2}:${shard1_port},${host3}:${shard1_port}')
sh.addShard('shard2/${host1}:${shard2_port},${host2}:${shard2_port},${host3}:${shard2_port}')
sh.addShard('shard3/${host1}:${shard3_port},${host2}:${shard3_port},${host3}:${shard3_port}')
db.printShardingStatus()
" > $confjs

echo 'To add shards for init mongos'
cat $confjs
$mongo_cmd --nodb $con_confjs
rm $confjs
