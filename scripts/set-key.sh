#!/bin/bash

moja_key="$1.sh"
PM2_DIR=""
HOME_DIR=""
moja_home=""
hostName="http://47.97.210.118"
osType=`uname -s|tr '[A-Z]' '[a-z]'`

if [ $osType = "linux" ] ;then
  HOME_DIR="home"
elif [ $osType = "darwin" ] ;then
  HOME_DIR="Users"
else
  exit 1
fi

#判断命令是否存在
command_exists() {
	command -v "$@" > /dev/null 2>&1
}

#初始化安装目录
init_install_dir(){
  if [ -f "/$HOME_DIR/moja/install-mode" ] ; then
    PM2_DIR=/$HOME_DIR/moja
    moja_home=/$HOME_DIR/moja/.moja
  else
    crontab -l | grep -v '.moja' |crontab -
    moja_home=~/.moja
    PM2_DIR=~
  fi
}

#重复安装kill pm2 和 应用进程
kill_process(){
  if [ $osType = "darwin" ] ;then
    kill -9 $(ps -ef|grep "$PM2_DIR/.pm2"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
    kill -9 $(ps -ef|grep "$moja_home/client"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
  fi

  if [ $osType = "linux" ] ;then
    g++ -v
    if [ $? -ne 0 ] ; then
      if command_exists yum ; then
        yum install gcc-c++ -y
      else
        apt-get install gcc-c++ -y
      fi
    fi
    ps -ef|grep -w "$PM2_DIR/.pm2"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
    ps -ef|grep -w "$moja_home/client"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
  fi
}

clear_and_init_app_dir(){
  rm -r -f $moja_home/stage
  rm -r -f $moja_home/client
  rm -r -f $moja_home/moja-version
  rm -r -f $moja_home/publicKey.js
  rm -r -f $moja_home/pmtwo
  rm -r -f $moja_home/moja-cloud-server-host
  rm -r -f ~/.moja_key
  mkdir ~/.moja
  touch ~/.moja_key
  touch $moja_home/publicKey.js
  touch $moja_home/email.js
  touch $moja_home/moja-cloud-server-host
  touch $moja_home/stage
  mkdir /var/tmp/client-logs

  echo $hostName > $moja_home/moja-cloud-server-host
  echo "module.exports ={email:\`$email\`}" > $moja_home/email.js
  echo "module.exports ={publicKey:\`$publicKey\`}" > $moja_home/publicKey.js
  if [ ! -f "$moja_home/terminalId.js" ]; then
     touch $moja_home/terminalId.js
     echo "module.exports =\"\";" > $moja_home/terminalId.js
  fi
  if [ ! -f "$moja_home/userId.js" ]; then
    touch $moja_home/userId.js
    echo "module.exports =\"\";" > $moja_home/userId.js
  fi
  rm -r -f $moja_home/$moja_key
  mkdir $moja_home/client
  mkdir $moja_home/client/tmpFile
}

#安装应用
install_app(){
  curl -o $moja_home/$moja_key $hostName/shells/$moja_key
  publickey=`cat $moja_home/$moja_key |grep "publicKey="|awk -F '"' '{print $2}'`
  email=`cat $moja_home/$moja_key |grep "email="|awk -F '"' '{print $2}'`
  clientVersion=`cat $moja_home/$moja_key |grep "clientVersion="|awk -F '"' '{print $2}'`

  echo $clientVersion > $moja_home/moja-version
  echo "module.exports ={publicKey:\`$publickey\`}" > $moja_home/publicKey.js
  echo "module.exports ={email:\`$email\`}" > $moja_home/email.js
  #echo "{user_key:$moja_key}" > ~/.moja_key

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

  cp -r -f $clientPath/deamon $moja_home/client
  cp -r -f $clientPath/handleLog $moja_home/client

  rm -r -f $clientPath.tar.gz
  rm -r -f $moja_home/$moja_key

  mv $moja_home/client/remote-terminal-client-v$clientVersion/start.js $moja_home/client
  cd $moja_home/client/remote-terminal-client-v$clientVersion

  npm config set loglevel=http --userconfig=~/.npmrc
  npm config set registry=https://registry.cnpmjs.org --userconfig=~/.npmrc

  npm install --unsafe-perm=true
}

add_crontab_list(){
  if [ ! -f "/$HOME_DIR/moja/install-mode" ] ; then
    mkdir ~/.moja/pmtwo
    npm install pm2 --unsafe-perm=true --prefix ~/.moja/pmtwo
    (echo "*/1 * * * * sh $moja_home/client/deamon/deamon.sh $PATH" ;crontab -l) | crontab
    (echo "1 0 * * */1 sh $moja_home/client/handleLog/tarLog.sh" ;crontab -l) | crontab
    (echo "@reboot sh $moja_home/client/deamon/deamon.sh $PATH" ;crontab -l) | crontab
  fi
}

init_install_dir
kill_process
clear_and_init_app_dir
install_app
add_crontab_list