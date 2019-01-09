#!/bin/bash

if ! moja
then
  echo "turiueriuwteiutwiuetiuwqi"
  mojaPAth=`sudo find / -name moja-terminal  -type d`
  echo $mojaPAth
  sudo ln -s mojaPAth/bin/moja
fi