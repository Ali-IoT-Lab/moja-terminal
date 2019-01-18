#!/bin/bash

findNpm="\`npm |grep npm@| awk -F ' ' '{print \$2}'|awk -F '/npm' '{print \$1}'\`"
command_exists() {
	command -v "$@" > /dev/null 2>&1
}

if ! command_exists npm ; then
  echo -e "\033[31m 请手动执行：sudo ln -s $findNpm/moja-terminal/bin/moja /usr/bin/moja \033[0m"
  exit 0
fi

modulePath=`npm |grep npm@| awk -F ' ' '{print $2}'|awk -F '/npm' '{print $1}'`

if ! command_exists moja ; then
  echo -e "\033[31m 请手动执行：sudo ln -s $modulePath/moja-terminal/bin/moja /usr/bin/moja \033[0m"
fi