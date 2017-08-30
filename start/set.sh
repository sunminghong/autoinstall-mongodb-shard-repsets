#!/bin/bash


# 配置集群主机的IP，本脚本目前只支持3台集群，更多的需要修改完善下 initsets.sh
hosts=(192.168.1.52 192.168.1.53 192.168.1.54)

# 配置第一台 mongos ip，用于初始化user连接 
mongos1=192.168.1.52

#配置各个mongodb数据文件、logs存放的路径，最终会生成：
# $descPath -- shard1 -- logs
#            |        |- db
#            |-shard2 ...
#            |-config ...
#            |-mongos ...
descPath=/data/mongo


#配置各个服务的端口号
shard1_port=270x1
shard2_port=270x2
shard3_port=270x3
config_port=27x00
mongos_port=27x00



host1=$hosts[0]
host2=$hosts[1]
host3=$hosts[2]


shardname="mongo-shard"
configname="mongo-config"
mongosname="mongos"

sharddir=$descPath/shard
configdir=$descPath/config
mongosdir=$descPath/mongos


confjs="${configdir}/conf.js"
con_confjs=$confjs


CONFIGDB=config/$host1:$config_port,$host2:$config_port,$host3:$config_port

mongo_cmd="mongo "
