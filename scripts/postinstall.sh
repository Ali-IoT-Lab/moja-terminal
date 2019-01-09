#!/bin/bash

modulePath=`npm |grep npm@| awk -F ' ' '{print $2}'|awk -F '/npm' '{print $1}'`

if ! moja
then
  mojaPath= "$modulePath/moja-terminal/bin/moja"
  echo "请手动执行======>>>>>：sudo ln -s $mojaPath /usr/bin/moja"
fi