#!/bin/bash

moja_key=$1
mkdir ~/.moja
touch ~/.moja
hostName="http://47.97.210.118"
function moja_file_init
{
  touch $1/publicKey.js
  touch $1/email.js
  touch $1/moja-cloud-server-host
  touch $1/stage
  touch $1/terminalId.js
  touch $1/userId.js
  mkdir /var/tmp/client-logs
  chmod 777 $1/email.js
  chmod 777 $1/userId.js
  chmod 777 $1/publicKey.js
  chmod 777 /var/tmp/client-logs

  echo $hostName > $1/moja-cloud-server-host
  echo "module.exports =\"\";" > $1/userId.js
  echo "module.exports =\"\";" > $1/terminalId.js
  echo "module.exports ={email:\`$email\`}" > $1/email.js
  echo "module.exports ={publicKey:\`$publicKey\`}" > $1/publicKey.js
  npm install --prefix $1 pm2 --unsafe-perm  --registry https://registry.cnpmjs.org
}

function moja_client_init
{
  basepath=$(cd `dirname $0`; pwd)
  rm -r -f basepath/$moja_key
  mkdir $1/client
  curl -o $basepath/$moja_key $hostName/shells/$moja_key

  publickey=`cat $basepath/$moja_key |grep "publicKey="|awk -F '"' '{print $2}'`
  email=`cat $basepath/$moja_key |grep "email="|awk -F '"' '{print $2}'`
  clientVersion=`cat $basepath/$moja_key |grep "clientVersion="|awk -F '"' '{print $2}'`

  echo $clientVersion > $1/moja-version
  echo "module.exports ={publicKey:\`$publickey\`}" > $1/publicKey.js
  echo "module.exports ={email:\`$email\`}" > $1/email.js
  echo "{user_key:$moja_key}" > ~/.moja

  clientPath="$1/client/remote-terminal-client-v$clientVersion"
  curl -o $clientPath.tar.gz $hostName/api/remote-terminal/tar/remote-terminal-client-v$clientVersion.tar.gz

  if [ $? -ne 0 ] ; then
    echo "客户端安装包下载失败!"
    exit 1
  fi

  mkdir $1/client/remote-terminal-client-v$clientVersion
  cd $1
  tar -xvf $clientPath.tar.gz --strip 1 -C $1/client/remote-terminal-client-v$clientVersion
  if [ $? -ne 0 ] ; then
    echo "客户端安装包解压失败!"
    exit 1
  fi

  rm -r -f $clientPath.tar.gz
  rm -r -f $basepath/$moja_key

  mv $1/client/remote-terminal-client-v$clientVersion/start.js $1/client
  cd $1/client/remote-terminal-client-v$clientVersion

  npm install --unsafe-perm=true
}

moja_file_init ~/.moja
moja_client_init ~/.moja
