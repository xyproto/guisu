#!/bin/sh

####################################################
#                                                  #
# GuiSu 0.4                                        #
#                                                  #
# A script for running a GUI program as root       #
#                                                  #
# Alexander Rødseth, 2013                          #
# MIT license                                      #
#                                                  #
####################################################

ELF="$0.elf"
ARGS="$@"

if [ ! -e "$ELF" ]; then
  echo 'GuiSu 0.4'
  echo
  echo 'Usage:'
  echo '  Create a symbolic link to guisu, where the name'
  echo '  of the executable + .elf results in the path'
  echo '  to the elf file you wish to run as root.'
  echo
  echo 'For example, if you wish to run /usr/bin/app.elf'
  echo 'as root. Create a symbolic link:'
  echo
  echo '  ln -s /usr/bin/guisu /usr/bin/app'
  echo
  echo 'Then when running /usr/bin/app, guisu will kick in'
  echo 'and run /usr/bin/app.elf as root by trying to run'
  echo 'the application with: pkexec, gksudo, gksu, kdesudo'
  echo 'and kdesu, in that order.'
  echo
  exit 1
fi

# --- Figure out what the current situation is ---

hasagent=no

if tty -s; then
  terminal=yes
else
  terminal=no
fi

if [ -z "$KDE_FULL_SESSION" ]; then
  kde=no
else
  kde=yes
fi

# --- Start agents if they aren't running ---

if [ $terminal == yes ]; then
  # Start pkttyagent if it's not running
  if [ -x /usr/bin/pkttyagent ]; then
    pgrep pkttyagent || pkttyagent &
    hasagent=yes
  fi
else
  if [ $kde == yes ]; then
    # Start the KDE polkit authentication agent if it's not running
    if [ -x /usr/lib/kde4/libexec/polkit-kde-authentication-agent-1 ]; then
      pgrep polkit-kde-authentication-agent-1 || /usr/lib/kde4/libexec/polkit-kde-authentication-agent-1 &
      hasagent=yes
    fi
  else
    # Start the GNOME polkit authentication agent if it's not running
    if [ -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]; then
      pgrep polkit-gnome-authentication-agent-1 || /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
      hasagent=yes
    fi
  fi
fi

if [ $hasagent == yes ]; then
  if [ -x /usr/bin/pkexec ]; then
    pkexec "$ELF" "$ARGS" && exit 0
  fi
fi

# --- Fall back on the old ways ---

if [ $kde == no ]; then
  if [ -x /usr/bin/gksudo ]; then
      gksudo "$ELF" "$ARGS" && exit 0
  fi
  if [ -x /usr/bin/gksu ]; then
      gksu "$ELF" "$ARGS" && exit 0
  fi
  if [ $terminal == yes ]; then
    echo 'Could not use pkexec, gksudo or gksu'
  fi
else
  if [ -x /usr/bin/kdesudo ]; then
    kdesudo "$ELF" "$ARGS" && exit 0
  fi
  if [ -e /usr/bin/kdesu ]; then
    kdesu "$ELF" "$ARGS" && exit 0
  fi
  if [ terminal == yes ]; then
    echo 'Could not use kdesudo or kdesu'
  fi
fi  

# --- Last resort ---

"$ELF" "$ARGS"
