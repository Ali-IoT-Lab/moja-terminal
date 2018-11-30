#!/bin/bash



npm config set unsafe-perm
command_exists() {
	command -v "$@" > /dev/null 2>&1
}

g++ -v
if [ $? -ne 0 ] ; then
  if command_exists yum ; then
    yum install gcc-c++ -y
  else
    apt-get install gcc-c++ -y
  fi
fi

npm config unset unsafe-perm