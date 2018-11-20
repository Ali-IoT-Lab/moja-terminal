#!/bin/bash

HOME_DIR=""
osType=`uname -s|tr '[A-Z]' '[a-z]'`

if [ $osType = "darwin" ] ;then
  HOME_DIR='Users'
fi

if [ $osType = "linux" ] ;then
  HOME_DIR='home'
fi

clientVersion=`cat /$HOME_DIR/moja/.moja/moja-version`
nodePath="/$HOME_DIR/moja/.moja/nodejs/bin/node"
$nodePath /$HOME_DIR/moja/.moja/client/start.js $clientVersion
if [ $? -ne 0 ] ; then
  echo "启动服务失败!"
  exit 1
fi