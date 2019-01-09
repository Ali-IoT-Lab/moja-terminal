#!/bin/bash

if ! moja
then
  path=`npm |grep npm@| awk -F ' ' '{print $2}'|awk -F '/npm' '{print $1}'`;
  mojaPath= $path/moja-terminal/bin/moja
  echo "请手动执行======>>>>>：sudo ln -s $mojaPath /usr/bin/moja"
fi