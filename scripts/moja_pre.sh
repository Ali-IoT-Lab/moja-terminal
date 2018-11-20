#!/bin/bash
osType=`uname -s|tr '[A-Z]' '[a-z]'`
HOME_DIR=""
hostName='http://47.97.210.118'
function moja_file_init
{
  touch $1/publicKey.js
  touch $1/email.js
  touch $1/moja-cloud-server-host
  touch $1/stage
  touch $1/terminalId.js
  touch $1/userId.js

  echo $hostName > $1/moja-cloud-server-host
  echo "module.exports =\"\";" > $1/userId.js
  echo "module.exports =\"\";" > $1/terminalId.js
  echo "module.exports ={email:\`$email\`}" > $1/email.js
  echo "module.exports ={publicKey:\`$publicKey\`}" > $1/publicKey.js
}

if [ $osType = "linux" ] ;then
  HOME_DIR='home'
elif [ $osType = "darwin" ] ;then
  HOME_DIR='Users'
else
  echo "不支持的系统类型！"
  exit 1
fi

mkdir /$HOME_DIR/moja
mkdir /$HOME_DIR/moja/.moja

moja_file_init /$HOME_DIR/moja/.moja
npm install --prefix /$HOME_DIR/moja/.moja pm2 --unsafe-perm  --registry https://registry.cnpmjs.org