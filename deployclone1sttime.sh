#!/bin/bash

FLAG="/var/log/firstboot.log"
if [ ! -f $FLAG ]; then
   #Put here your initialization sentences
   echo "This is the first boot"
   perl /root/vmreconfig/postreconfig.pl >/var/log/firstboot.log 2>&1

   #the next line creates an empty file so it won't run the next boot
   touch $FLAG
else
   echo "Flag exists, do not run. Do nothing"
fi
