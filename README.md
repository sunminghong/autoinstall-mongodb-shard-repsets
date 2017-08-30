# autoinstall-mongodb-shard-repsets
bash script for auto install mongodb shard Replica Sets；mongodb切片复制集群自动安装脚本

# 架设mongodb切片复制集群自动化脚本

mongodb 现在用得越来越多了，2016年下半年我司开始应用mongodb，现在主要用来记录日志和储存离线计算中间数据。随着数据量以及应用越来越多，mongodb现在处理越来越慢，于是开始架设切片集群用于离线计算用。为了方便以后架设，我将它写成了一个bash 脚本，也就实现了自动化部署。

### 一、mongodb 切片复制集群，主要有三个角色：

1、切片服务shard
    数据最终就是存在各个切片服务器上，每个shard可以有1～n台复制集群类似mysql的主从结构，其中一台当机，另一个会自动启用。为了当机时更好的自动选出主库，一般会配置一个仲裁节点。

2、配置服务 config
    保存所有的切片相关的数据功能mongos使用，为了避免单点故障，一般也是配置成一个主从复制集，有1～n个服务。

3、路由服务器 mongos
    对切片服务器的访问必须要对数据进行路由、分片、组合等，这些任务由mongos服务完成；mongos是对外访问的入口，也就是说对mongodb读写数据、用户管理等都是连接mongos。mongos可以由多个，一般程序访问就近的mongos，这样可以减少数据IO。

**小结： **   
1、一个mongodb切片复制集群里，shard 存储数据，config保存各类切片配置，mongos提供对外访问；  
2、mongos可以有多个，mongos只负责数据查询、路由等功能，mongos当机只会是的不能访问mongodb，不会造成数据库任何问题。


根据我们当前的业务需要，这个集群只有三台，也是比较常见的配置，128G*32核*3台，三个shard（每个shard有来个复制和一个仲裁）、三个config、三个mongos，也就是每台服务器上有3个shard进程、1个config进程、1个mongos进程。

配置mongodb Replica Sets 主要有以下步骤：

1、环境搭建：ssh互通；所有服务器安装上mongodb，不同系统不同，这里略过； 
2、配置shard，并启动shard  
3、配置config，并启动  
4、配置mongos，并启动  
5、初始化user（建立admin／root账号）  
6、停止所有进程  
7、生成keyfile 并 确保所有进程访问的是一样内容的keyfile 
8、重启所有进程（加上--keyfile参数，确保各个服务间安全通讯）  


### 二、自动化脚本使用步骤

**1、配置 start/set.sh**
```
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


```

**2、运行autoinstall.sh**
* 为了方便重复执行各个步骤，自动化脚本运行后首先会询问一些选择项，请大家结合以上步骤，选择y/n

```
$bash autoinstall.sh

if remove keyfile[y/n]:
if make keyfile[y/n]:
if clear history files[y/n]:
if scp files[y/n]:
if install mongo shards and config process[y/n]:
if init shard & config[y/n]:
if start mongos[y/n]:
if init admin/root user[y/n]:
if stop all mongo processes[y/n]:
if restart[y/n]:
if clear install files[y/n]:
```

其中 "if clear history files[y/n]:" 如果选择y，就是将之前安装的全部清除了，包括数据！！！  
其中 "if clear history files[y/n]:" 如果选择y，就是将之前安装的全部清除了，包括数据！！！  
其中 "if clear history files[y/n]:" 如果选择y，就是将之前安装的全部清除了，包括数据！！！  



### 三、应用  
1、mongodb 默认是对数据库不进行shard，但是会自动将不同的数据库放到各个shard服务器上存储；要应用shard，需要先对数据库启用切片：
> sh.enableSharding("<database>")

2、对需要shard的collection进行切片配置，主要就是要指定切片条件（索引，指定的字段会制动建立一个复合索引）
> sh.shardCollection("<database>.<collection>", { <key> : <direction> } )


完整的请见 [https://github.com/sunminghong/autoinstall-mongodb-shard-repsets](https://github.com/sunminghong/autoinstall-mongodb-shard-repsets)





