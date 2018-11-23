module.exports ={
  set_key: function (moja_key) {
    return `
     #!/bin/bash
      mkdir ~/.moja
      touch ~/.moja_key
      moja_home=~/.moja
      hostName="http://47.97.210.118"
      function moja_file_init
      {
        touch $moja_home/publicKey.js
        touch $moja_home/email.js
        touch $moja_home/moja-cloud-server-host
        touch $moja_home/stage
        touch $moja_home/terminalId.js
        touch $moja_home/userId.js
        touch $moja_home/install-mode
        mkdir /var/tmp/client-logs
        chmod 777 $moja_home/email.js
        chmod 777 $moja_home/userId.js
        chmod 777 $moja_home/publicKey.js
        chmod 777 /var/tmp/client-logs
      
        echo "npm" > $moja_home/install-mode
        echo $hostName > $moja_home/moja-cloud-server-host
        echo "module.exports =\\"\\";" > $moja_home/userId.js
        echo "module.exports =\\"\\";" > $moja_home/terminalId.js
        echo "module.exports ={email:\\\`$email\\\`}" > $moja_home/email.js
        echo "module.exports ={publicKey:\\\`$publicKey\\\`}" > $moja_home/publicKey.js
        node_modules_path=echo \`which moja\`|awk -F 'moja' '{print $1}'
      }
      
      function moja_client_init
      {
        basepath=~/.moja
        rm -r -f basepath/`+moja_key+`
        mkdir $moja_home/client
        curl -o $basepath/`+moja_key+` $hostName/shells/`+moja_key+`
      
        publickey=\`cat $basepath/`+moja_key+` |grep "publicKey="|awk -F '"' '{print $2}'\`
        email=\`cat $basepath/`+moja_key+` |grep "email="|awk -F '"' '{print $2}'\`
        clientVersion=\`cat $basepath/`+moja_key+` |grep "clientVersion="|awk -F '"' '{print $2}'\`
      
        echo $clientVersion > $moja_home/moja-version
        echo "module.exports ={publicKey:\\\`$publickey\\\`}" > $moja_home/publicKey.js
        echo "module.exports ={email:\\\`$email\\\`}" > $moja_home/email.js
        #echo "{user_key:`+moja_key+`}" > ~/.moja_key
      
        clientPath="$moja_home/client/remote-terminal-client-v$clientVersion"
        curl -o $clientPath.tar.gz $hostName/api/remote-terminal/tar/remote-terminal-client-v$clientVersion.tar.gz
      
        if [ $? -ne 0 ] ; then
          echo "客户端安装包下载失败!"
          exit 1
        fi
      
        mkdir $moja_home/client/remote-terminal-client-v$clientVersion
        cd $moja_home
        tar -xvf $clientPath.tar.gz --strip 1 -C $moja_home/client/remote-terminal-client-v$clientVersion
        if [ $? -ne 0 ] ; then
          echo "客户端安装包解压失败!"
          exit 1
        fi
      
        rm -r -f $clientPath.tar.gz
        rm -r -f $basepath/`+moja_key+`
      
        mv $moja_home/client/remote-terminal-client-v$clientVersion/start.js $moja_home/client
        cd $moja_home/client/remote-terminal-client-v$clientVersion
      
        npm install --unsafe-perm=true --registry https://registry.cnpmjs.org
      }
      
      moja_file_init ~/.moja
      
      moja_client_init ~/.moja
    `
  }
}