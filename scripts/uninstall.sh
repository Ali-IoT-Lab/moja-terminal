#!/bin/bash

HOME_DIR=""
osType=`uname -s|tr '[A-Z]' '[a-z]'`

if [ $osType = "darwin" ] ;then
  HOME_DIR='Users'
  #sed -i "/.moja/d" /var/spool/cron/`whoami`
fi

if [ $osType = "linux" ] ;then
  HOME_DIR='home'
  sed -i "/.moja/d" /var/spool/cron/`whoami`
fi

#/Users/moja/.moja/lib/node_modules/pm2/bin/pm2
pm2Path="/$HOME_DIR/moja/.moja/lib/node_modules/pm2/bin/pm2"
logPath="/var/tmp/client-logs"
rm -r -f $logPath

$pm2Path kill
$pm2Path delete all

rm -r -f /$HOME_DIR/moja
rm -r -f $logPath

