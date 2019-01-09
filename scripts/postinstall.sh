#!/bin/bash


modulePath=`npm |grep npm@| awk -F ' ' '{print $2}'|awk -F '/npm' '{print $1}'`
moja
if [ $? -ne 0 ] ; then
  echo -e "\033[31m 请手动执行：sudo ln -s $modulePath/moja-terminal/bin/moja /usr/bin/moja \033[0m"
fi