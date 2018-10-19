#!/bin/bash


osType=`uname -s|tr '[A-Z]' '[a-z]'`

if [ $osType = "darwin" ] ;then
  HOME_DIR='Users'
fi
if [ $osType = "linux" ] ;then
  HOME_DIR='home'
fi

envrun="sudo -u moja env PATH=$PATH:/$HOME_DIR/moja/.moja/nodejs/bin"
logPath="/var/tmp/client-logs"
logsTarPath="/var/tmp/client-logs-tar"
pm2Path="/$HOME_DIR/moja/.moja/nodejs/bin/pm2"

$envrun $pm2Path flush

echo > $logPath/err.log
echo > $logPath/out.log
deleteTar=`cd /var/tmp/client-logs-tar;ls -lrt *.tar|head -1|awk -F ' ' '{print $NF}'`
rotateCount=`cd /var/tmp/client-logs-tar;ls -l|grep .tar|wc -l`

if [ $rotateCount -gt 7 ] ;then
  rm -r -f $logsTarPath/$deleteTar
fi


