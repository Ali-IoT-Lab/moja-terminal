#!/bin/bash
osType=`uname -s|tr '[A-Z]' '[a-z]'`

function moja_file_init
{
  touch $1/publicKey.js
  touch $1/email.js
  touch $1/moja-cloud-server-host
  mkdir $1/client-source
  touch $1/stage
  touch $1/terminalId.js
  touch $1/userId.js

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
elif [ $osType = "darwin" ] ;then
  mkdir /Users/moja
  mkdir /Users/moja/.moja
  moja_file_init /Users/moja/.moja
  npm install --prefix /Users/moja/.moja pm2 --unsafe-perm  --registry https://registry.cnpmjs.org
else
  echo "不支持的系统类型！"
  exit 1
fi

hostName=`cat /$HOME_DIR/moja/.moja/moja-cloud-server-host|tr -d '\n'`
clientPath="/$HOME_DIR/moja/.moja/remote-terminal-client"
curl -o $clientPath.tar.gz $hostName/api/remote-terminal/tar/remote-terminal-client.tar.gz
if [ $? -ne 0 ] ; then
  echo "客户端安装包下载失败"
  exit 1
fi
tar -xvf clientPath.tar.gz -C /$HOME_DIR/moja/.moja
if [ $? -ne 0 ] ; then
  echo "客户端安装包解压失败"
  exit 1
fi

rm -r -f clientPath.tar.gz