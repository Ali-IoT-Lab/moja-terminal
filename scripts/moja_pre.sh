#!/bin/bash
osType=`uname -s|tr '[A-Z]' '[a-z]'`

function moja_file_init
{
  touch $1/publicKey.js
  touch $1/email.js
  touch $1/moja-version
  touch $1/moja-cloud-server-host
  mkdir $1/client-source
  touch $1/stage
  touch $1/terminalId.js
  touch $1/userId.js

  echo `npm view moja-terminal version` > $1/moja-version
  echo 'http://xuyaofang.com' > $1/moja-cloud-server-host
  echo "module.exports =\"\";" > $1/userId.js
  echo "module.exports =\"\";" > $1/terminalId.js
  echo "module.exports ={email:\`$email\`}" > $1/email.js
  echo "module.exports ={publicKey:\`$publicKey\`}" > $1/publicKey.js
}

if [ $osType = "linux" ] ;then
  mkdir /home/moja
  mkdir /home/moja/.moja
  moja_file_init /home/moja/.moja
  npm install --prefix /home/moja/.moja pm2 --unsafe-perm  --registry https://registry.cnpmjs.org
  npm install --prefix /home/moja/.moja moja-terminal --unsafe-perm  --registry https://registry.cnpmjs.org
elif [ $osType = "darwin" ] ;then
  mkdir /Users/moja
  mkdir /Users/moja/.moja
  moja_file_init /Users/moja/.moja
  npm install --prefix /Users/moja/.moja pm2 --unsafe-perm  --registry https://registry.cnpmjs.org
  npm install --prefix /Users/moja/.moja moja-terminal --unsafe-perm  --registry https://registry.cnpmjs.org
else
  echo "不支持的系统类型！"
  exit 1
fi