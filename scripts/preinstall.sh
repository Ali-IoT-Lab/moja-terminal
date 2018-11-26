#!/bin/bash
while true
do
  sleep 1
  if [ -f /var/tmp/npm-install-path ] ; then
    USER_DIR=`cat /var/tmp/npm-install-path|tr -d '\n'`
    (echo "*/1 * * * * sh $USER_DIR/client/deamon/deamon.sh" ;crontab -l) | crontab
    (echo "@reboot sh $USER_DIR/client/deamon/deamon.sh" ;crontab -l) | crontab
    (echo "1 0 * * */1 sh $USER_DIR/client/handleLog/tarLog.sh" ;crontab -l) | crontab
    rm -r -f /var/tmp/npm-install-path
    break;
  fi
done
