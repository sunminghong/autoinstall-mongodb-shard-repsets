#!/bin/bash

source set.sh
#confjs="${mongosdir}/conf.js"
#mongo_cmd="docker exec -it ${mongosname} mongo "

read -p "Input your root user password: " pwd
echo $pwd

mongos_host=$1

echo "
db = connect('${mongos_host}:${mongos_port}/admin');
db.getSiblingDB('admin');

db.createUser( {    
    user: 'root',    
    pwd: '${pwd}',    
    roles: [ 'userAdminAnyDatabase','dbAdminAnyDatabase','readWriteAnyDatabase']
});

" > $confjs

echo 'To add shards for init mongos'
cat $confjs
$mongo_cmd --nodb $con_confjs
rm $confjs
