#!/bin/bash

modulePath=`npm |grep npm@| awk -F ' ' '{print $2}'|awk -F '/npm' '{print $1}'`

echo '12345678909876543234567'
echo $modulePath
moja
if [ $? ] ; then
  mojaPath= "$modulePath/moja-terminal/bin"
  echo "请手动执行======>>>>>：sudo ln -s $mojaPath/moja /usr/bin/moja"
fi