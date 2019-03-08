#!/bin/bash
moja_key="$1"

if [ $1 ] ;then
  echo "$1" > ~/.moja_key
else
  echo "invalid parameters!"
  exit 1
fi