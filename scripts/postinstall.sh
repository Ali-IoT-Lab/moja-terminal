#!/bin/bash

if ! moja
then
  echo "turiueriuwteiutwiuetiuwqi"
  mojaPAth=`find / -name moja-terminal  -type d`
  echo $mojaPAth
  ln -s mojaPAth/bin/moja
fi