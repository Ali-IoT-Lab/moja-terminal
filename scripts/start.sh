#!/bin/bash

clientVersion=''
publickey=''
email=''
moja_home=~/.moja
currHOME=~
hostName="http://47.97.210.118"

osType=`uname -s|tr '[A-Z]' '[a-z]'`

#第一步 根据KEY获取配置文件publicKey terminalId userId  读取key内容
moja_key=`cat $currHOME/.moja_key|tr -d '\n'`
curl -o $moja_home/$moja_key $hostName/shells/$moja_key
publickey=`cat $moja_home/$moja_key |grep "publicKey="|awk -F '"' '{print $2}'`
email=`cat $moja_home/$moja_key |grep "email="|awk -F '"' '{print $2}'`
clientVersion=`cat $moja_home/$moja_key |grep "clientVersion="|awk -F '"' '{print $2}'`


#清除目录

if [ $osType = "darwin" ] ;then
  kill -9 $(ps -ef|grep "$currHOME/.pm2"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
  kill -9 $(ps -ef|grep "$moja_home/client"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
fi

if [ $osType = "linux" ] ;then
  ps -ef|grep -w "$currHOME/.pm2"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
  ps -ef|grep -w "$moja_home/client"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
fi

mkdir ~/mojaId
if [ -f "$moja_home/terminalId.js" ]; then
  cp -r -f $moja_home/terminalId.js ~/mojaId/terminalId.js
fi
if [ -f "$moja_home/userId.js" ]; then
  cp -r -f $moja_home/userId.js ~/mojaId/userId.js
fi

rm -r -f ~/.moja
rm -r -f /var/tmp/client-logs
mkdir -p ~/.moja/client/v$clientVersion
mkdir ~/.moja/pmtwo
touch $moja_home/publicKey.js
touch $moja_home/email.js
touch $moja_home/moja-cloud-server-host
touch $moja_home/stage
touch $moja_home/moja-version
mkdir /var/tmp/client-logs

echo $clientVersion > $moja_home/moja-version
echo "module.exports ={publicKey:\`$publickey\`}" > $moja_home/publicKey.js
echo "module.exports ={email:\`$email\`}" > $moja_home/email.js

if [ -f "$currHOME/mojaId/terminalId.js" ]; then
  mv ~/mojaId/terminalId.js $moja_home/terminalId.js
else
  touch $moja_home/terminalId.js
  echo "module.exports =\"\";" > $moja_home/terminalId.js
fi

if [ -f "$currHOME/mojaId/userId.js" ]; then
  mv ~/mojaId/userId.js $moja_home/userId.js
else
  touch $moja_home/userId.js
  echo "module.exports =\"\";" > $moja_home/userId.js
fi

rm -r -f ~/mojaId

#第二步 下载客户单代码
npm config set loglevel=http
npm install remote-terminal-client-test --unsafe-perm=true --registry=https://registry.cnpmjs.org --prefix ~/.moja/client/v$clientVersion
#第三步 安装pm2
export HOME=$moja_home
npm install pm2 --unsafe-perm=true --registry=https://registry.cnpmjs.org --prefix ~/pmtwo
#第四步 启动项目
node ~/client/v$clientVersion/node_modules/remote-terminal-client-test/start.js $clientVersion
#第五步 添加计划任务定时器
