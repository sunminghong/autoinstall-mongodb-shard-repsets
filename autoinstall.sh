#!/bin/bash


#引入一配置文件
source start/set.sh

default=$1

read -p "if remove keyfile[y/n]: " ifremovekeyfile
read -p "if make keyfile[y/n]: " ifkeyfile
read -p "if clear history files[y/n]: " ifremove
read -p "if scp files[y/n]: " ifscp
read -p "if install mongo shards and config process[y/n]: " ifinstall
read -p "if init shard & config[y/n]: " ifinitset
read -p "if start mongos[y/n]: " ifstartmongos
read -p "if init admin/root user[y/n]: " ifinituser
read -p "if stop all mongo processes[y/n]: " ifstopall
read -p "if restart[y/n]: " ifrestart
read -p "if clear install files[y/n]: " ifclear



if [[ "$ifremovekeyfile" == "y" ]]; then
rm conf/keyfile
for host in ${hosts[@]};do
    echo $host
    ssh -T $host << EOF 
    rm -f /etc/mongo/keyfile
EOF
done
fi


if [[ "$ifkeyfile" == "y" ]]; then
if [ -f "conf/keyfile" ]; then
    echo 'has conf/keyfile'
else
    openssl rand -base64 755 > conf/keyfile
    chmod 400 conf/keyfile
fi
fi


#循环执行 清理现场
if [[ "$ifremove" == "y" ]]; then
rm conf/keyfile
for host in ${hosts[@]};do
    echo $host
    ssh -T $host << EOF 

    ps aux | grep mongo
    echo "kill all mongod"

    killall mongod
    killall mongos
    rm -rf $descPath
    rm -f /etc/mongo/keyfile
    ps aux | grep mongo

EOF
done
fi

#copy 安装文件到各个服务器
if [[ "$ifscp" == "y" ]]; then
for host in ${hosts[@]};do
    echo $host
    ssh -T $host mkdir -p $descPath

    scp -rp conf $host:$descPath/
    scp -rp start $host:$descPath/

    ssh -T $host << EOF 
    cd $descPath/start
    mkdir /etc/mongo
EOF
done
fi



#循环执行 初步安装mongodb
if [[ "$ifinstall" == "y" ]]; then
for host in ${hosts[@]};do
    echo $host
    ssh -T $host << EOF 
    cd $descPath/start
    bash installmongoset.sh shard 1
    bash installmongoset.sh shard 2
    bash installmongoset.sh shard 3 
    bash installmongoset.sh config 1
EOF

done
fi

for host in ${hosts[@]};do
    echo $host
    ssh -T $host << EOF 
    ps aux | grep mongo

EOF
done

#循环执行 配置mongo shard&config repsets
if [[ "$ifinitset" == "y" ]]; then
cd start
bash initsets.sh 1
bash initsets.sh 2
bash initsets.sh 3
fi


#循环执行 启动安装mongos
if [[ "$ifstartmongos" == "y" ]]; then
for host in ${hosts[@]};do
    echo $host
    ssh -T $host << EOF 
    cd $descPath/start
    bash installmongoset.sh mongos 1
    bash initmongos.sh
EOF

done
fi


#循环执行 配置user and role
if [[ "$ifinituser" == "y" ]]; then
cd start
bash inituser.sh $host1
cd ..
fi


#停止所有进程，重新启动，带上keyfile参数
if [[ "$ifstopall" == "y" ]]; then

sleep 5

for host in ${hosts[@]};do
    echo $host
    ssh -T $host << EOF 

    ps aux | grep mongo
    echo "kill all mongod"

    killall mongod
    killall mongos

sleep 1

    killall mongod
    killall mongos

    sleep 2

    ps aux | grep mongo
EOF
done
fi

if [[ "$ifrestart" == "y" ]]; then

sleep 5

for host in ${hosts[@]};do
    echo $host
    ssh -T $host << EOF 
    cd $descPath/start
    mkdir /etc/mongo
    mv ../conf/keyfile /etc/mongo/
    bash startmongoset.sh config 1
EOF
done

for host in ${hosts[@]};do
    echo $host
    ssh -T $host << EOF 
    cd $descPath/start
    mkdir /etc/mongo
    mv ../conf/keyfile /etc/mongo/
    bash startmongoset.sh shard 1
    bash startmongoset.sh shard 2
    bash startmongoset.sh shard 3 
    bash startmongoset.sh mongos 1

    sleep 5
    ps aux | grep mongo
EOF
done
fi


#收工，删除安装文件
if [[ "$ifclear" == "y" ]]; then
for host in ${hosts[@]};do
    echo $host
    ssh -T $host << EOF 
    cd $descPath
    rm -rf conf
    rm -rf start

EOF
rm conf/keyfile

done
fi



