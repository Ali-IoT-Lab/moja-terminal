#!/bin/bash


export HOME=~/.moja
moja_key="$1.sh"

if [ $1 ] ;then
  echo "$1.sh" > ~/.moja_key
else
  echo "invalid parameters!"
  exit 1
fi