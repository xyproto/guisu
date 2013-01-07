#!/bin/sh
#
####################################################
#                                                  #
# PonySu 0.3                                       #
#                                                  #
# A script for running a GUI program as root       #
#                                                  #
# Alexander Rødseth, 2013                          #
# MIT license                                      #
#                                                  #
####################################################
#
ELF="$0.elf"
ARGS="$@"
if [ ! -e "$ELF" ]; then
  echo 'PonySu 0.3'
  echo
  echo 'Usage:'
  echo '  Create a symbolic link to ponysu, where the name'
  echo '  of the executable + .elf results in the path'
  echo '  to the elf file you wish to run as root.'
  echo
  echo 'For example, if you wish to run /usr/bin/app.elf'
  echo 'as root. Create a symbolic link:'
  echo
  echo '  ln -s /usr/bin/ponysu /usr/bin/app'
  echo
  echo 'Then when running /usr/bin/app, ponysu will kick in'
  echo 'and run /usr/bin/app.elf as root by trying to run'
  echo 'the application with: pkexec, gksudo, gksu, kdesudo'
  echo 'and kdesu, in that order.'
  echo
  exit 1
fi
if [ -e /usr/bin/pkexec ]; then
  pkexec "$ELF" "$ARGS" && exit 0
fi
if [ -z "$KDE_FULL_SESSION" ]; then
  if [ -e /usr/bin/gksudo ]; then
      gksudo "$ELF" "$ARGS" && exit 0
  fi
  if [ -e /usr/bin/gksu ]; then
      gksu "$ELF" "$ARGS" && exit 0
  fi
  echo 'Could not use pkexec, gksudo or gksu'
  "$ELF" "$ARGS" && exit 0 || exit 1
fi  
if [ -e /usr/bin/kdesudo ]; then
  kdesudo "$ELF" "$ARGS" && exit 0
fi
if [ -e /usr/bin/kdesu ]; then
  kdesu "$ELF" "$ARGS" && exit 0
fi
echo 'Could not use kdesudo or kdesu'
"$ELF" "$ARGS"
