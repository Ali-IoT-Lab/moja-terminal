#!/bin/bash

HOME_DIR=""
osType=`uname -s|tr '[A-Z]' '[a-z]'`

if [ $osType = "darwin" ] ;then
  HOME_DIR='Users'
fi

if [ $osType = "linux" ] ;then
  HOME_DIR='home'
fi

pm2Path="/$HOME_DIR/moja/.moja/lib/node_modules/pm2/bin/pm2"
clientPath="/$HOME_DIR/moja/.moja/moja-terminal"
logPath="/var/tmp/client-logs"
appPath="/$HOME_DIR/moja/.moja/moja-terminal/app.js"
clientVersion=`npm view moja-terminal version`
$pm2Path start $appPath --log-type json --merge-logs --log-date-format="YYYY-MM-DD HH:mm:ss Z" -o $logPath/out.log -e $logPath/err.log --name moja-terminal-v$clientVersion