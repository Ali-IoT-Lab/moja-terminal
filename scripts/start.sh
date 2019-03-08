#!/bin/bash

clientVersion=''
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

#读取用户key
moja_key=`cat $currHOME/.moja_key|tr -d '\n'`.sh

#判断用户key是否为空
if [ -z "$moja_key" ]; then
  echo "请设置用户key！"
  exit 1
fi

#根据脚本名下载脚本
curl -o $moja_home/$moja_key $hostName/shells/$moja_key

#读取脚本中当前版本号
clientVersion=`cat $moja_home/$moja_key |grep "clientVersion="|awk -F '"' '{print $2}'`

#启动项目
node $moja_home/client/v$clientVersion/node_modules/remote-terminal-client/start.js $clientVersion


