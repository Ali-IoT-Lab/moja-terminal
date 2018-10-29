#!/bin/bash
currPath=$(cd "$(dirname "$0")";pwd)
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
if [ $# -eq 2 ] ; then
	echo "dasdhlkhslfhsldhjflkhsjd"
	echo $2
  curl -o $2 $hostName$filePath/$1
else
  echo "非法的参数!"
  exit 1
fi
