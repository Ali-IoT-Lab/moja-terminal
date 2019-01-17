#!/bin/bash

clientVersion=''
publickey=''
email=''
moja_home=~/.moja
currHOME=~
hostName="http://47.97.210.118"
osType=`uname -s|tr '[A-Z]' '[a-z]'`
mkdir $moja_home

#第一步 根据KEY获取配置文件publicKey terminalId userId  读取key内容
moja_key=`cat $currHOME/.moja_key|tr -d '\n'`
curl -o $moja_home/$moja_key $hostName/shells/$moja_key
publickey=`cat $moja_home/$moja_key |grep "publicKey="|awk -F '"' '{print $2}'`
email=`cat $moja_home/$moja_key |grep "email="|awk -F '"' '{print $2}'`
clientVersion=`cat $moja_home/$moja_key |grep "clientVersion="|awk -F '"' '{print $2}'`

#kill进程
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
#清除目录
rm -r -f $moja_home
rm -r -f /var/tmp/client-logs
mkdir -p $moja_home/client/v$clientVersion
mkdir $moja_home/pmtwo
mkdir $moja_home/tmpFile
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
npm install remote-terminal-client-test --unsafe-perm=true --registry=https://registry.cnpmjs.org --prefix $moja_home/client/v$clientVersion
#第三步 安装pm2
npm install pm2 --unsafe-perm=true --registry=https://registry.cnpmjs.org --prefix ~/.moja/pmtwo
#第四步 启动项目
node $moja_home/client/v$clientVersion/node_modules/remote-terminal-client-test/start.js $clientVersion
#第五步 添加计划任务定时器

mv $moja_home/client/v$clientVersion/node_modules/remote-terminal-client-test/deamon $moja_home/
mv $moja_home/client/v$clientVersion/node_modules/remote-terminal-client-test/handleLog $moja_home/

(echo "*/1 * * * * sh $moja_home/deamon/deamon.sh $PATH" ;crontab -l) | crontab
(echo "1 0 * * */1 sh $moja_home/handleLog/tarLog.sh" ;crontab -l) | crontab
(echo "@reboot sh $moja_home/deamon/deamon.sh $PATH" ;crontab -l) | crontab