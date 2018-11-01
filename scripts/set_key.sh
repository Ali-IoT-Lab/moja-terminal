#!/bin/bash

option=$1
moja_key=$2
HOME_DIR=""
osType=`uname -s|tr '[A-Z]' '[a-z]'`
if [ $osType = "darwin" ] ;then
  HOME_DIR='Users'
fi
if [ $osType = "linux" ] ;then
  HOME_DIR='home'
fi
if [ $option = "-k" ] ; then
  echo "module.exports ={publicKey:\`$moja_key\`}" > /$HOME_DIR/moja/.moja/publicKey.js
fi
if [ $option = "-e" ] ; then
  echo "module.exports ={email:\`$moja_key\`}" > /$HOME_DIR/moja/.moja/email.js
fi