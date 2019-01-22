#!/bin/bash

clientVersion=''
publickey=''
email=''
moja_home=~/.moja
currHOME=~

basepath=$(cd `dirname $0`; pwd)
hostName=`sed '/^mojaHostName=/!d;s/.*=//' $basepath/config`

osType=`uname -s|tr '[A-Z]' '[a-z]'`
if [ $osType = "linux" ] ;then
  curlHOME='/home/moja'
elif [ $osType = "darwin" ] ;then
  curlHOME='/Users/moja'
else
  exit 1
fi

#创建安装公共目录
mkdir ~/.moja

#判断用户key 文件是否存在
if [ ! -f "$currHOME/.moja_key" ]; then
  echo "请设置用户key！"
  exit 1
fi

#读取用户key
moja_key=`cat $currHOME/.moja_key|tr -d '\n'`

#判断用户key是否为空
if [ -z "$moja_key" ]; then
  echo "请设置用户key！"
  exit 1
fi

#根据脚本名下载脚本
curl -o $moja_home/$moja_key $hostName/shells/$moja_key

#读取脚本中服务端公钥
publickey=`cat $moja_home/$moja_key |grep "publicKey="|awk -F '"' '{print $2}'`

#读取脚本中用户邮箱
email=`cat $moja_home/$moja_key |grep "email="|awk -F '"' '{print $2}'`

#读取脚本中当前版本号
clientVersion=`cat $moja_home/$moja_key |grep "clientVersion="|awk -F '"' '{print $2}'`

#重复安装则kill之前的进程
if [ $osType = "darwin" ] ;then
  kill -9 $(ps -ef|grep "$currHOME/.pm2"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
  kill -9 $(ps -ef|grep "$moja_home/client"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
fi

if [ $osType = "linux" ] ;then
  ps -ef|grep -w "$currHOME/.pm2"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
  ps -ef|grep -w "$moja_home/client"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
fi

#暂存已经安装的用户Id
mkdir ~/mojaId
if [ -f "$moja_home/terminalId.js" ]; then
  cp -r -f $moja_home/terminalId.js ~/mojaId/terminalId.js
fi
if [ -f "$moja_home/userId.js" ]; then
  cp -r -f $moja_home/userId.js ~/mojaId/userId.js
fi

#清除目录 并初始化安装目录和文件
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

#下载客户端代码
npm config set loglevel=http
npm install remote-terminal-client --unsafe-perm=true --registry=https://registry.cnpmjs.org --prefix $moja_home/client/v$clientVersion

#安装pm2
npm install pm2 --unsafe-perm=true --registry=https://registry.cnpmjs.org --prefix ~/.moja/pmtwo

#将定时任务脚本移动到公共目录
rm -r -f $moja_home/deamon
rm -r -f $moja_home/handleLog
mv $moja_home/client/v$clientVersion/node_modules/remote-terminal-client/deamon $moja_home
mv $moja_home/client/v$clientVersion/node_modules/remote-terminal-client/handleLog $moja_home

#启动项目
node $moja_home/client/v$clientVersion/node_modules/remote-terminal-client/start.js $clientVersion

#判断安装方式是否为curl 链接安装， 添加计划任务定时器
if [ ! -f "$curlHOME/install-mode" ] ; then
  crontab -l | grep -v '.moja' |crontab -
  (echo "*/1 * * * * sh $moja_home/deamon/deamon.sh $PATH" ;crontab -l) | crontab
  (echo "1 0 * * */1 sh $moja_home/handleLog/tarLog.sh" ;crontab -l) | crontab
  (echo "@reboot sh $moja_home/deamon/deamon.sh $PATH" ;crontab -l) | crontab
fi



