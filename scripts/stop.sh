#!/bin/bash

moja_home=~/.moja
currHOME=~
osType=`uname -s|tr '[A-Z]' '[a-z]'`

if [ $osType = "linux" ] ;then
  curlHOME='/home/moja'
  ps -ef|grep -w "$currHOME/.pm2"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
  ps -ef|grep -w "$moja_home/client"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
elif [ $osType = "darwin" ] ;then
  curlHOME='/Users/moja'
  kill -9 $(ps -ef|grep "$currHOME/.pm2"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
  kill -9 $(ps -ef|grep "$moja_home/client"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
else
  echo "--------------------------------------不支持的系统类型---------------------------------------"
  exit 1
fi