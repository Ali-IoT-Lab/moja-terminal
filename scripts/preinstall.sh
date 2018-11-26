#!/bin/bash

USER_DIR=$1
(echo "*/1 * * * * sh $USER_DIR/client/deamon/deamon.sh" ;crontab -l) | crontab
(echo "@reboot sh $USER_DIR/client/deamon/deamon.sh" ;crontab -l) | crontab
(echo "1 0 * * */1 sh $USER_DIR/client/handleLog/tarLog.sh" ;crontab -l) | crontab
rm -r -f /var/tmp/npm-install-path