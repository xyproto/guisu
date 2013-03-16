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
  echo 'the application with: pkexec and gksu in that'
  echo 'order, and falls back to terminal, if no GUI found.'
  echo
  exit 1
fi

# --- Start an agent if it isn't running ---

hasagent=no

if pgrep ^cinnamon &> /dev/null || \
   pgrep ^gnome-shell &> /dev/null || \
   pgrep ^lxpolkit &> /dev/null || \
   pgrep ^polkit-gnome &> /dev/null || \
   pgrep ^polkit-kde &> /dev/null; then
  # A polkit authentication agent is already running
  hasagent=yes
elif [ -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]; then
  # Start the GNOME polkit authentication agent
  /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 & sleep 0.5
  hasagent=yes
elif [ -x /usr/lib/lxpolkit/lxpolkit ]; then
  # Start the LXPolkit authentication agent
  /usr/lib/lxpolkit/lxpolkit & sleep 0.5
  hasagent=yes
fi

# --- Run pkexec with graphical agent ---

if [ $hasagent == yes ]; then
  if [ -x /usr/bin/pkexec ]; then
    pkexec --disable-internal-agent "$ELF" "$ARGS"
    exit 0
  fi
fi

# --- Fall back on the old ways ---

if [ -x /usr/bin/gksu ]; then
    gksu "$ELF" "$ARGS"
    exit 0
fi

# --- Fall back to terminal ---

if tty -s; then
  if [ -x /usr/bin/pkexec ]; then
    pkexec "$ELF" "$ARGS"
    exit 0
  fi
  if [ -x /usr/bin/sudo ]; then
    sudo "$ELF" "$ARGS"
    exit 0
  fi
fi

# --- Last resort ---

"$ELF" "$ARGS"
