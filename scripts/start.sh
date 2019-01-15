#!/bin/bash

HOME_DIR
clientVersion=''
publickey=''
email=''
moja_home=~/.moja
hostName="http://47.97.210.118"

osType=`uname -s|tr '[A-Z]' '[a-z]'`
if [ $osType = "linux" ] ;then
  HOME_DIR="home"
elif [ $osType = "darwin" ] ;then
  HOME_DIR="Users"
else
  exit 1
fi

#第一步 根据KEY获取配置文件publicKey terminalId userId  读取key内容
moja_key=`cat ~/.moja_key|tr -d '\n'`
curl -o ~/$moja_key $hostName/shells/$moja_key
publickey=`cat ~/$moja_key |grep "publicKey="|awk -F '"' '{print $2}'`
email=`cat ~/$moja_key |grep "email="|awk -F '"' '{print $2}'`
clientVersion=`cat ~/$moja_key |grep "clientVersion="|awk -F '"' '{print $2}'`

mkdir -p client/v$clientVersion
#清除目录

if [ $osType = "darwin" ] ;then
  kill -9 $(ps -ef|grep "~/.pm2"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
  kill -9 $(ps -ef|grep "~/.moja/client"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
fi

if [ $osType = "linux" ] ;then
  ps -ef|grep -w "~/.pm2"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
  ps -ef|grep -w "~/.moja/client"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
fi

mkdir ~/mojaId
if [ -f "$moja_home/terminalId.js" ]; then
  cp -r -f $moja_home/terminalId.js ~/mojaId
fi
if [ -f "$moja_home/userId.js" ]; then
  cp -r -f $moja_home/userId.js ~/mojaId
fi


rm -r -f ~/.moja
rm -r -f /var/tmp/client-logs
mkdir -p $moja_home
touch $moja_home/publicKey.js
touch $moja_home/email.js
touch $moja_home/moja-cloud-server-host
touch $moja_home/stage
touch $moja_home/moja-version
mkdir /var/tmp/client-logs

mkdir ~/.moja/pmtwo
mkdir ~/.moja/client

echo $clientVersion > $moja_home/moja-version
echo "module.exports ={publicKey:\`$publickey\`}" > $moja_home/publicKey.js
echo "module.exports ={email:\`$email\`}" > $moja_home/email.js

if [ -f "~/mojaId/terminalId.js" ]; then
  cp ~/mojaId/terminalId.js $moja_home/terminalId.js
else
  touch $moja_home/terminalId.js
  echo "module.exports =\"\";" > $moja_home/terminalId.js
fi

if [ -f "~/mojaId/userId.js" ]; then
  cp ~/mojaId/userId.js $moja_home/userId.js
else
  touch $moja_home/userId.js
  echo "module.exports =\"\";" > $moja_home/userId.js
fi

rm -r -f ~/mojaId

#第二步 下载客户单代码
npm config set loglevel=http
npm install remote-terminal-client-test --unsafe-perm=true --registry=https://registry.cnpmjs.org --prefix ~/.moja/client/v$clientVersion
#第三步 安装pm2
npm install pm2 --unsafe-perm=true --registry=https://registry.cnpmjs.org --prefix ~/.moja/pmtwo
#第四步 启动项目
node ~/.moja/client-v$clientVersion/node_modules/remote-terminal-client-test/start.js $clientVersion
#第五步 添加计划任务定时器




///////////////////////
#!/bin/bash

clientVersion=''
publickey=''
email=''
moja_home=~/.moja
hostName="http://47.97.210.118"
#第一步 根据KEY获取配置文件publicKey terminalId userId  读取key内容
moja_key=`cat ~/.moja_key|tr -d '\n'`
curl -o ~/$moja_key $hostName/shells/$moja_key
publickey=`cat ~/$moja_key |grep "publicKey="|awk -F '"' '{print $2}'`
email=`cat ~/$moja_key |grep "email="|awk -F '"' '{print $2}'`
clientVersion=`cat ~/$moja_key |grep "clientVersion="|awk -F '"' '{print $2}'`

#清除目录
rm -r -f ~/.moja
rm -r -f /var/tmp/client-logs
mkdir -p $moja_home
touch $moja_home/publicKey.js
touch $moja_home/email.js
touch $moja_home/moja-cloud-server-host
touch $moja_home/stage
touch $moja_home/moja-version
mkdir /var/tmp/client-logs

mkdir ~/.moja/pmtwo
mkdir ~/.moja/client

echo $clientVersion > $moja_home/moja-version
echo "module.exports ={publicKey:\`$publickey\`}" > $moja_home/publicKey.js
echo "module.exports ={email:\`$email\`}" > $moja_home/email.js



#第二步 下载客户单代码
npm config set loglevel=http
npm install remote-terminal-client-test --unsafe-perm=true --registry=https://registry.cnpmjs.org --prefix ~/.moja/client
#第三步 安装pm2
npm install pm2 --unsafe-perm=true --registry=https://registry.cnpmjs.org --prefix ~/.moja/pmtwo
#第四步 启动项目
sleep 3
#node ~/.moja/client/node_modules/remote-terminal-client-test/start.js $clientVersion

#第五步 添加计划任务定时器



