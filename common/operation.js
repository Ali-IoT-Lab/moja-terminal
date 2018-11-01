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
  set_key: function (option,moja_key) {
    return `#!/bin/bash
      option=`+option+`
      HOME_DIR=""
      osType=\`uname -s|tr '[A-Z]' '[a-z]'\`
      if [ $osType = "darwin" ] ;then
        HOME_DIR='Users'
      fi
      if [ $osType = "linux" ] ;then
        HOME_DIR='home'
      fi
      if [ $option = "-k" ] ; then
        echo "module.exports ={publicKey:\\\``+moja_key+`\\\`}" > /$HOME_DIR/moja/.moja/publicKey.js
      fi
      if [ $option = "-e" ] ; then
        echo "module.exports ={email:\\\``+moja_key+`\\\`}" > /$HOME_DIR/moja/.moja/email.js
      fi`
  }
}
