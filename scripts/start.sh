#!/bin/bash


preHOME=~
export HOME=$preHOME/.moja

$HOME
clientVersion=''
publickey=''
email=''
hostName="http://47.97.210.118"

osType=`uname -s|tr '[A-Z]' '[a-z]'`

#第一步 根据KEY获取配置文件publicKey terminalId userId  读取key内容
moja_key=`cat $HOME/.moja_key|tr -d '\n'`
curl -o $preHOME/$moja_key $hostName/shells/$moja_key
publickey=`cat $HOME/$moja_key |grep "publicKey="|awk -F '"' '{print $2}'`
email=`cat $HOME/$moja_key |grep "email="|awk -F '"' '{print $2}'`
clientVersion=`cat $HOME/$moja_key |grep "clientVersion="|awk -F '"' '{print $2}'`

#清除目录
if [ $osType = "darwin" ] ;then
  kill -9 $(ps -ef|grep "$HOME/.pm2"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
  kill -9 $(ps -ef|grep "$HOME/client"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
fi

if [ $osType = "linux" ] ;then
  ps -ef|grep -w "$HOME/.pm2"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
  ps -ef|grep -w "$HOME/client"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
fi

mkdir $preHOME/mojaId
if [ -f "$HOME/terminalId.js" ]; then
  cp -r -f $HOME/terminalId.js ~/mojaId/terminalId.js
fi
if [ -f "$HOME/userId.js" ]; then
  cp -r -f $HOME/userId.js ~/mojaId/userId.js
fi

rm -r -f $HOME
rm -r -f /var/tmp/client-logs
mkdir -p $HOME/client/v$clientVersion
mkdir $HOME/pmtwo
touch $HOME/publicKey.js
touch $HOME/email.js
touch $HOME/moja-cloud-server-host
touch $HOME/stage
touch $HOME/moja-version
mkdir /var/tmp/client-logs

echo $clientVersion > $HOME/moja-version
echo "module.exports ={publicKey:\`$publickey\`}" > $HOME/publicKey.js
echo "module.exports ={email:\`$email\`}" > $HOME/email.js

if [ -f "$HOME_DIR/mojaId/terminalId.js" ]; then
  mv $preHOME/mojaId/terminalId.js $HOME/terminalId.js
else
  touch $HOME/terminalId.js
  echo "module.exports =\"\";" > $HOME/terminalId.js
fi

if [ -f "$HOME_DIR/mojaId/userId.js" ]; then
  mv $preHOME/mojaId/userId.js $HOME/userId.js
else
  touch $HOME/userId.js
  echo "module.exports =\"\";" > $HOME/userId.js
fi

rm -r -f $preHOME/mojaId

#第二步 下载客户单代码
npm config set loglevel=http
npm install remote-terminal-client-test --unsafe-perm=true --registry=https://registry.cnpmjs.org --prefix ~/.moja/client/v$clientVersion
#第三步 安装pm2
npm install pm2 --unsafe-perm=true --registry=https://registry.cnpmjs.org --prefix ~/.moja/pmtwo
#第四步 启动项目
node $HOME/client/v$clientVersion/node_modules/remote-terminal-client-test/start.js $clientVersion
#第五步 添加计划任务定时器
