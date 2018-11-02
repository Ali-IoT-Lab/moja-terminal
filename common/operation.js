module.exports ={
  start:`#!/bin/bash
  HOME_DIR=""
  osType=\`uname -s|tr '[A-Z]' '[a-z]'\`
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
  clientVersion=\`npm view moja-terminal version\`
  mkdir /var/tmp/client-logs
  $pm2Path start $appPath --log-type json --merge-logs --log-date-format="YYYY-MM-DD HH:mm:ss Z" -o $logPath/out.log -e $logPath/err.log --name moja-terminal-v$clientVersion`,
  set_key: function (moja_key) {
    return `#!/bin/bash
    moja_key=`+moja_key+`
    HOME_DIR=""
    touch ~/.moja
    osType=\`uname -s|tr '[A-Z]' '[a-z]'\`
    if [ $osType = "darwin" ] ;then
      HOME_DIR='Users'
    fi
    
    if [ $osType = "linux" ] ;then
      HOME_DIR='home'
    fi
    
    hostName=\`cat /$HOME_DIR/moja/.moja/moja-cloud-server-host|tr -d '\\n'\`
    curl -o ./$moja_key $hostName/shells/$moja_key
    publickey=\`cat ./$moja_key |grep "publicKey="|awk -F '"' '{print $2}'\`
    email=\`cat ./$moja_key |grep "email="|awk -F '"' '{print $2}'\`
    publicKey=\`echo -n $publickey| base64 -d\`
    echo "module.exports ={publicKey:\\\`$publicKey\\\`}" > /$HOME_DIR/moja/.moja/publicKey.js
    echo "module.exports ={email:\\\`$email\\\`}" > /$HOME_DIR/moja/.moja/email.js
    echo "{user_key:$moja_key}" > ~/.moja`
  }
}
