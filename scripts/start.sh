#!/bin/bash

clientVersion=''
publickey=''
email=''
moja_home=~/.moja
hostName="http://47.97.210.118"
#第一步 根据KEY获取配置文件publicKey terminalId userId  读取key内容
moja_key=`cat ~/.moja_key|tr -d '\n'`
curl -o ~/$moja_key $hostName/shells/$moja_key
publickey=`cat ~/$moja_key |grep "publicKey="|awk -F '"' '{print $2}'`
email=`cat ~/$moja_key |grep "email="|awk -F '"' '{print $2}'`
clientVersion=`cat ~/$moja_key |grep "clientVersion="|awk -F '"' '{print $2}'`

touch -p $moja_home/publicKey.js
touch $moja_home/email.js
touch $moja_home/moja-cloud-server-host
touch $moja_home/stage
touch $moja_home/moja-version
mkdir /var/tmp/client-logs

echo $clientVersion > $moja_home/moja-version
echo "module.exports ={publicKey:\`$publickey\`}" > $moja_home/publicKey.js
echo "module.exports ={email:\`$email\`}" > $moja_home/email.js

mkdir ~/.moja/pmtwo
mkdir ~/.moja/client

#第二步 下载客户单代码
npm install remote-terminal-client --unsafe-perm=true --registry=https://registry.cnpmjs.org --prefix ~/.moja/client
#第三步 安装pm2
npm install remote-terminal-client --unsafe-perm=true --registry=https://registry.cnpmjs.org --prefix ~/.moja/pmtwo
#第四步 启动项目

node ~/.moja/client/node_modules/remote-terminal-client/start.js

#第五步 添加计划任务定时器



