#!/bin/bash
moja_key=$1
hostName="http://47.97.210.118"
HOME_DIR=""
touch ~/.moja
osType=`uname -s|tr '[A-Z]' '[a-z]'`
if [ $osType = "darwin" ] ;then
  HOME_DIR='Users'
fi

if [ $osType = "linux" ] ;then
  HOME_DIR='home'
fi

basepath=$(cd `dirname $0`; pwd)
rm -r -f basepath/$moja_key
mkdir /$HOME_DIR/moja/.moja/client
curl -o $basepath/$moja_key $hostName/shells/$moja_key

publickey=`cat $basepath/$moja_key |grep "publicKey="|awk -F '"' '{print $2}'`
email=`cat $basepath/$moja_key |grep "email="|awk -F '"' '{print $2}'`
clientVersion=`cat $basepath/$moja_key |grep "clientVersion="|awk -F '"' '{print $2}'`

echo $clientVersion > /$HOME_DIR/moja/.moja/moja-version
echo "module.exports ={publicKey:\`$publickey\`}" > /$HOME_DIR/moja/.moja/publicKey.js
echo "module.exports ={email:\`$email\`}" > /$HOME_DIR/moja/.moja/email.js
echo "{user_key:$moja_key}" > ~/.moja


clientPath="/$HOME_DIR/moja/.moja/client/remote-terminal-client-v$clientVersion"
curl -o $clientPath.tar.gz $hostName/api/remote-terminal/tar/remote-terminal-client-v$clientVersion.tar.gz

if [ $? -ne 0 ] ; then
  echo "客户端安装包下载失败!"
  exit 1
fi
mkdir /$HOME_DIR/moja/.moja/client/remote-terminal-client-v$clientVersion
cd /$HOME_DIR/moja/.moja/
tar -xvf $clientPath.tar.gz --strip 1 -C /$HOME_DIR/moja/.moja/client/remote-terminal-client-v$clientVersion
if [ $? -ne 0 ] ; then
  echo "客户端安装包解压失败!"
  exit 1
fi

rm -r -f $clientPath.tar.gz
rm -r -f $basepath/$moja_key
mv /$HOME_DIR/moja/.moja/client/remote-terminal-client-v$clientVersion/start.js /$HOME_DIR/moja/.moja/client
cd /$HOME_DIR/moja/.moja/client/remote-terminal-client-v$clientVersion
npm install --unsafe-perm=true

currUser=`whoami`
currGroup=`ls -l|grep $currUser|awk -F ' ' '{print$4}'`
chown -R $currUser:$currGroup /$HOME_DIR/moja

