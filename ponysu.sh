#!/bin/sh
#
####################################################
#                                                  #
# PonySu 0.1                                       #
#                                                  #
# A script for running a GUI program as root       #
#                                                  #
# Alexander Rødseth, 2013                          #
# MIT license                                      #
#                                                  #
####################################################
#
ELF="$0.elf"
if [ ! -e "$ELF" ]; then
  echo 'PonySu 0.1'
  echo
  echo 'Usage:'
  echo '  Create a symbolic link to ponysu, where the name'
  echo '  of the exexecutable + .elf results in the path'
  echo '  to the elf file you wish to run as root.'
  echo
  exit 1
fi
if [ -e /usr/bin/pkexec ]; then
  pkexec $ELF && exit 0
fi
if [ -z "$KDE_FULL_SESSION" ]; then
  if [ -e /usr/bin/gksudo ]; then
      gksudo $ELF && exit 0
  fi
  if [ -e /usr/bin/gksu ]; then
      gksu $ELF && exit 0
  fi
  echo 'Could not use pkexec, gksudo or gksu'
  $ELF && exit 0 || exit 1
fi  
if [ -e /usr/bin/kdesudo ]; then
  kdesudo $ELF && exit 0
fi
if [ -e /usr/bin/kdesu ]; then
  kdesu $ELF && exit 0
fi
echo 'Could not use kdesudo or kdesu'
$ELF
