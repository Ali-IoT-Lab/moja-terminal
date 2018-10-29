#!/bin/bash

HOME_DIR=""

osType=`uname -s|tr '[A-Z]' '[a-z]'`
if [ $osType = "linux" ] ;then
  HOME_DIR="home"
elif [ $osType = "darwin" ] ;then
  HOME_DIR="Users"
else
  echo "-----------------------------------不支持的系统类型------------------------------------"
  exit 1
fi
hostName=`cat /$HOME_DIR/moja/.moja/moja-cloud-server-host|tr -d '\n'`
logPath="/var/tmp/client-logs"
pm2Path="/$HOME_DIR/moja/.moja/nodejs/bin/pm2"
clientPath="/$HOME_DIR/moja/.moja/moja-terminal"
appPath="/$HOME_DIR/moja/.moja/moja-terminal/app.js"
clientPath="/$HOME_DIR/moja/.moja/moja-terminal"
envrun="sudo -u moja env PATH=$PATH:/$HOME_DIR/moja/.moja/nodejs/bin"
oldVersion=`cat /$HOME_DIR/moja/.moja/moja-version`

echo "--------------------------------------备份旧版本---------------------------------------"
rm -r -f clientPath.tar.gz
mv /$HOME_DIR/moja/.moja/moja-terminal /$HOME_DIR/moja/
echo "--------------------------------------下载新版本---------------------------------------"
curl -o $clientPath.tar.gz $hostName/api/remote-terminal/tar/moja-terminal.tar.gz
echo "--------------------------------------解压新版本---------------------------------------"
tar -xvf /$HOME_DIR/moja/.moja/moja-terminal.tar.gz -C /$HOME_DIR/moja/.moja
rm -r -f /$HOME_DIR/moja/.moja/moja-terminal.tar.gz
echo "-----------------------------------加载新版本代码-----------------------------------"
if [ `whoami` = 'moja' ] ; then
  pm2 start $appPath --log-type json --merge-logs --log-date-format="YYYY-MM-DD HH:mm:ss Z" -o $logPath/out.log -e $logPath/err.log --name client-v$newClientVersion
  result=$?
else
  $envrun $pm2Path start $appPath --log-type json --merge-logs --log-date-format="YYYY-MM-DD HH:mm:ss Z" -o $logPath/out.log -e $logPath/err.log --name client-v$newClientVersion
  result=$?
fi

if [ $result -ne 0 ] ; then
echo "----------------------------------升级失败回退到旧版本代码---------------------------------"
  rm -r -f $clientPath
  mv /$HOME_DIR/moja/moja-terminal /$HOME_DIR/moja/.moja/
else
  if [ ! -f "/$HOME_DIR/moja/.moja/moja-version" ];then
    if [ `whoami` = 'moja' ] ; then
      pm2 delete app
    else
      $envrun $pm2Path delete app
    fi
  else
    if [ `whoami` = 'moja' ] ; then
      pm2 delete client-v$oldVersion
    else
      $envrun $pm2Path delete client-v$oldVersion
    fi
  fi
fi