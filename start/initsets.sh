#!/bin/bash

source set.sh

#configuration shard server replication's nodes

#localip=$(/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:")
#result=$(echo $localip | grep "${host1}")
#if [[ "$result" != "" ]]
#then
#    serv_no="1"
#fi

#result=$(echo $localip | grep "${host2}")
#if [[ "$result" != "" ]]
#then
#    serv_no="2"
#fi

#result=$(echo $localip | grep "${host3}")
#if [[ "$result" != "" ]]
#then
#    serv_no="3"
#fi

serv_no=$1
echo $serv_no


#if [ -f "/etc/mongo/keyfile" ]; then
    #mongo_cmd="mongo --keyfile /etc/mongo/keyfile "
#fi



if [[ $serv_no == "1" ]]; then
	echo "
	db = connect('${host1}:${shard1_port}/admin');
	db.getSiblingDB('admin');
	conf={
	    _id: 'shard1',
	    members: [
		{_id: 1, host: '${host1}:${shard1_port}',priority:30, arbiterOnly: false},
		{_id: 2, host: '${host2}:${shard1_port}',priority:20, arbiterOnly: false},
		{_id: 3, host: '${host3}:${shard1_port}',priority:10, arbiterOnly: true}
	    ]
	};
	rs.initiate(conf);
	//rs.add('${host2}:${shard1_port}');
	//rs.add('${host3}:${shard1_port}');
	" > $confjs

	cat $confjs
	$mongo_cmd --nodb $con_confjs
	rm $confjs


	#set config replSets
	echo "
	db = connect('${host1}:${config_port}/admin');
	db.getSiblingDB('admin');

	conf={
	    _id: 'config',
	    members: [
		{_id: 1, host: '${host1}:${config_port}',priority:20, arbiterOnly: false},
		{_id: 2, host: '${host2}:${config_port}',priority:30, arbiterOnly: false},
		{_id: 3, host: '${host3}:${config_port}',priority:10, arbiterOnly: false}
	    ]
	};
	rs.initiate(conf);
	//rs.add('${host2}:${config_port}');
	//rs.add('${host3}:${config_port}');
	" > $confjs

	cat $confjs
	$mongo_cmd --nodb $con_confjs
	rm $confjs
fi



if [[ $serv_no == "2" ]]; then
	echo "
	db = connect('${host2}:${shard2_port}/admin');
	db.getSiblingDB('admin');
	conf={
	    _id: 'shard2',
	    members: [
		{_id: 1, host: '${host2}:${shard2_port}',priority:30, arbiterOnly: false},
		{_id: 2, host: '${host1}:${shard2_port}',priority:10, arbiterOnly: true},
		{_id: 3, host: '${host3}:${shard2_port}',priority:20, arbiterOnly: false}
	    ]
	};
	rs.initiate(conf);
	//rs.add('${host1}:${shard2_port}');
	//rs.add('${host3}:${shard2_port}');
	" > $confjs

	cat $confjs
	$mongo_cmd --nodb $con_confjs
	rm $confjs
fi


if [[ $serv_no == "3" ]]; then
	echo "
	db = connect('${host3}:${shard3_port}/admin');
	db.getSiblingDB('admin');
	conf={
	    _id: 'shard3',
	    members: [
		{_id: 1, host: '${host3}:${shard3_port}',priority:30, arbiterOnly: false},
		{_id: 2, host: '${host1}:${shard3_port}',priority:20, arbiterOnly: false},
		{_id: 3, host: '${host2}:${shard3_port}',priority:10, arbiterOnly: true}
	    ]
	};
	rs.initiate(conf);
	//rs.add('${host1}:${shard3_port}')
	//rs.add('${host2}:${shard3_port}')
	" > $confjs

	cat $confjs
	$mongo_cmd --nodb $con_confjs
	rm $confjs
fi
