#!/bin/bash

moja_key=$1
HOME_DIR=""
touch ~/.moja
osType=`uname -s|tr '[A-Z]' '[a-z]'`
if [ $osType = "darwin" ] ;then
  HOME_DIR='Users'
fi

if [ $osType = "linux" ] ;then
  HOME_DIR='home'
fi

hostName=`cat /$HOME_DIR/moja/.moja/moja-cloud-server-host|tr -d '\n'`
curl -o ./$moja_key $hostName/shells/$moja_key

publickey=`cat ./$moja_key |grep "publicKey="|awk -F '"' '{print $2}'`

email=`cat ./$moja_key |grep "email="|awk -F '"' '{print $2}'`
publicKey=`echo -n $publickey| base64 -d`
echo "module.exports ={publicKey:\`$publicKey\`}" > /$HOME_DIR/moja/.moja/publicKey.js
echo "module.exports ={email:\`$email\`}" > /$HOME_DIR/moja/.moja/email.js
echo "{user_key:$moja_key}" > ~/.moja
