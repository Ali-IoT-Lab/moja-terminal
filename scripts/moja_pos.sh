#!/bin/bash

osType=`uname -s|tr '[A-Z]' '[a-z]'`

if [ $osType = "linux" ] ;then
  mv /home/moja/.moja/lib/node_modules/moja-terminal /home/moja/.moja/
elif [ $osType = "darwin" ] ;then
  mv /Users/moja/.moja/lib/node_modules/moja-terminal /Users/moja/.moja/
else
  echo "不支持的系统类型！"
fi