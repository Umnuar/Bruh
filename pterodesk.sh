#!/bin/bash
# Copyright(C) 2024 nulldaemon. All rights reserved.
# !!! Unauthorized copies of this software will be treated lawfully. !!!
# *** THIS SOFTWARE IS UNDER PROPRIETARY ASSET. ALL BUT NOT LIMITED TO ACTIONS
#     SUCH AS COPYING, DISTRIBUTING, MODIFYING THE SOFTWAE WITHOUT PROPER AUTH
#     -ORIZATION IS CONSIDERED A "BREACH OF CONTRACT" AND CAN BE USED AGAINST
#     YOU AT ANY CIRCUMSTANCES. FAILING TO FOLLOW MAY LEAD TO SEVERE LEGAL CON
#     -SEQUENCES.                                  < nulldaemon license, v1.0 > ***

# >> ⚙️ User-Configuration ⚙️ <<
user_passwd="$HOSTNAME"
retailer_mode=false
retailer_prod="enabled retailer mode as an example"

# [ 🖧 Mirrors ]
mirror_alpine="https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/x86_64/alpine-minirootfs-3.20.2-x86_64.tar.gz"
mirror_proot="https://proot.gitlab.io/proot/bin/proot"

#  >> 👨🏻‍💻 | Runtime configuration (AUTOMATED) <<
if "$retailer_mode"; then install_path=$HOME/.subsystem; elif [ -n "$SERVER_PORT" ]; then install_path="$HOME/cache/$(echo "$HOSTNAME" | md5sum | sed 's+ .*++g')"; else install_path="./testing-arena"; fi

# Environment Variables
# firefox
export MOZ_DISABLE_CONTENT_SANDBOX=1 \
  MOZ_DISABLE_SOCKET_PROCESS_SANDBOX=1 \
  MOZ_DISABLE_RDD_SANDBOX=1 \
  MOZ_DISABLE_GMP_SANDBOX=1

d.stat() { echo -ne "\033[1;37m==> \033[1;34m$@\033[0m\n"; }
d.dftr() { echo -ne "\033[1;33m!!! DISABLED FEATURE: \033[1;31m$@ \033[1;33m!!!\n"; }
d.warn() { echo -ne "\033[1;33mwarning: \033[1;31m$@\[033;0m\n"; }

die() {
  echo -ne "\n\033[41m               \033[1;37mA FATAL ERROR HAS OCCURED               \033[0m\n"
  echo -ne "\033[1;33m   Please save the error logs and dm \033[1;32mn5ll\033[1;33m on\033[1;35m Discord\033[1;33m\033[0m\n"
  sleep 5
  exit 1
}

printlogo() {
  echo -ne "\033[1;33m!!! WARNING: THIS SCRIPT IS IN BETA STAGE; IF BUGS WERE TO BE FOUND, PLEASE DM \033[1;32mn5ll \033[1;33mON DISCORD. \033[1;33m!!!
\033[1;32m                .----.\033[1;35m    ██▓███  ▄▄▄█████▓▓█████  ██▀███   ▒█████  ▓█████▄ ▓█████   ██████  ██ ▄█▀
\033[1;32m    .---------. | == | \033[1;35m  ▓██░  ██▒▓  ██▒ ▓▒▓█   ▀ ▓██ ▒ ██▒▒██▒  ██▒▒██▀ ██▌▓█   ▀ ▒██    ▒  ██▄█▒ 
\033[1;32m    |.-\"\"\"\"\"-.| |----|\033[1;35m   ▓██░ ██▓▒▒ ▓██░ ▒░▒███   ▓██ ░▄█ ▒▒██░  ██▒░██   █▌▒███   ░ ▓██▄   ▓███▄░ 
\033[1;32m    ||       || | == |\033[1;35m   ▒██▄█▓▒ ▒░ ▓██▓ ░ ▒▓█  ▄ ▒██▀▀█▄  ▒██   ██░░▓█▄   ▌▒▓█  ▄   ▒   ██▒▓██ █▄ 
\033[1;32m    ||       || |----|\033[1;35m   ▒██▒ ░  ░  ▒██▒ ░ ░▒████▒░██▓ ▒██▒░ ████▓▒░░▒████▓ ░▒████▒▒██████▒▒▒██▒ █▄
\033[1;32m    |'-.....-'| |::::|\033[1;35m   ▒▓▒░ ░  ░  ▒ ░░   ░░ ▒░ ░░ ▒▓ ░▒▓░░ ▒░▒░▒░  ▒▒▓  ▒ ░░ ▒░ ░▒ ▒▓▒ ▒ ░▒ ▒▒ ▓▒
\033[1;32m    \`\"\")---(\"\"\` |___.|\033[1;35m   ░▒ ░         ░     ░ ░  ░  ░▒ ░ ▒░  ░ ▒ ▒░  ░ ▒  ▒  ░ ░  ░░ ░▒  ░ ░░ ░▒ ▒░
\033[1;32m   /:::::::::::\" _  \"\033[1;35m   ░░         ░         ░     ░░   ░ ░ ░ ░ ▒   ░ ░  ░    ░   ░  ░  ░  ░ ░░ ░ 
\033[1;32m  /:::=======:::\`\`\\033[1;35m                         ░  ░   ░         ░ ░     ░       ░  ░      ░  ░  ░
\033[1;32m  \`\"\"\"\"\"\"\"\"\"\"\"\"\"\`  '-'  \033[1;31m(C) 2024 nulldaemon, All rights reserved. \033[1;35m            ░
\033[1;31m                        $("$retailer_mode" && echo "Licensed to \033[1;32m${retailer_prod}(tm)\033[1;31m as an authorized retailer.")
\033[0m"
}
# <enddbg:displaylib>

# <dbgsym:bootstrap>
check_link="curl --output /dev/null --silent --head --fail"
bootstrap_system() {
  # Printing the watermark
  #printlogo

  _CHECKPOINT=$PWD

  d.stat "Initializing the Alpine rootfs image..."
  curl -L "$mirror_alpine" -o a.tar.gz && tar -xf a.tar.gz || die
  rm -rf a.tar.gz

  d.stat "Downloading a Docker Daemon..."
  curl -L "$mirror_proot" -o dockerd || die
  chmod +x dockerd

  d.stat "Bootstrapping system..."
  touch etc/{passwd,shadow,groups}

  # copy shit
  cp /etc/resolv.conf "$install_path/etc/resolv.conf" -v
  cp /etc/hosts "$install_path/etc/hosts" -v
  cp /etc/localtime "$install_path/etc/localtime" -v
  cp /etc/passwd "$install_path"/etc/passwd -v
  cp /etc/group "$install_path"/etc/group -v
  sed -i "s+1000+$(id -u)+g" "$install_path/etc/"{passwd,group}
  sed -i "s+/home/container+$install_path/home/container+g" "$install_path/etc/passwd"
  cp /etc/nsswitch.conf "$install_path"/etc/nsswitch.conf -v
  mkdir -p "$install_path/home/container"

  ./dockerd -r . -b /dev -b /sys -b /proc -b /tmp \
    --kill-on-exit -w /home/container /bin/sh -c "apk update && apk add bash xorg-server git python3 py3-pip py3-numpy xterm openssl; \
  	apk add xinit xvfb fakeroot firefox tigervnc icewm font-noto --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community; \
    apk add virtualgl mesa-dri-gallium --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing; \
    git clone https://github.com/notnulldaemon/noVNC && \
    cd noVNC
    openssl req -x509 -sha256 -days 356 -nodes -newkey rsa:2048 -subj '/CN=$(curl -L checkip.pterodactyl-installer.se)/C=US/L=San Fransisco' -keyout self.key -out self.crt && \
    cp vnc.html index.html && \
    ln -s /usr/bin/fakeroot /usr/bin/sudo && \
    pip install websockify --break-system-packages && \
    mkdir -p /home/container/.vnc && echo '$user_passwd' | vncpasswd -f > /home/container/.vnc/passwd"
  cat >"$install_path/home/container/.vnc/config" <<EOF
session=icewm
geometry=1600x800
rfbport=5901
EOF
  mkdir -p "$install_path/etc/firefox"
  curl -L "https://github.com/yokoffing/Betterfox/raw/main/user.js" -o "$install_path/etc/firefox/syspref.js"
}

# <dbgsym:run>
DOCKER_RUN="env - \
    HOME=$install_path/home/container $install_path/dockerd --kill-on-exit -r $install_path -b /dev -b /proc -b /sys \
    -b $install_path:$install_path /bin/sh -c"
run_system() {
  # abort if file
  if [ -f $HOME/.do-not-start ]; then
    rm -rf $HOME/.do-not-start
    cp /etc/resolv.conf "$install_path/etc/resolv.conf" -v
    $DOCKER_RUN /bin/sh
    exit
  fi

  rm -rf "$install_path/tmp"
  mkdir -p "$install_path/tmp"
  # Starting NoVNC
  d.stat "Starting noVNC server..."
  $install_path/dockerd --kill-on-exit -r $install_path -b /dev -b /proc -b /sys -b /tmp -w "/home/container/noVNC" /bin/sh -c "./utils/novnc_proxy --vnc localhost:5901 --listen 0.0.0.0:$SERVER_PORT --cert self.crt --key self.key" &>/dev/null &

  # start desktop server
  d.stat "Configuring desktop..."

  # running desktop
  d.stat "Starting desktop..."
  chmod 0600 "$install_path/home/container/.vnc/passwd" # prerequisite

  $DOCKER_RUN "export PATH=$install_path/bin:$install_path/usr/bin:$PATH HOME=$install_path/home/container LD_LIBRARY_PATH='$install_path/usr/lib:$install_path/lib:/usr/lib:/usr/lib64:/lib64:/lib'; \
    cd $install_path/home/container; \
    export MOZ_DISABLE_CONTENT_SANDBOX=1 \
    MOZ_DISABLE_SOCKET_PROCESS_SANDBOX=1 \
    MOZ_DISABLE_RDD_SANDBOX=1 \
    MOZ_DISABLE_GMP_SANDBOX=1; \
    vglrun -d egl vncserver :0" &>/dev/null &

  # eat shit and self destruct indefinitely
  # layer got the script noooo

  "$retailer_mode" || {
    sleep 1
    clear
    echo "Loading libraries, please wait..."
    while true; do sleep 29343924923592352353; done # a fucking random
  }                                                 # integer
  printlogo
  d.stat "Your server is now available at \033[1;32mhttps://$(curl --silent -L checkip.pterodactyl-installer.se):$SERVER_PORT"
  $DOCKER_RUN bash
  while true; do sleep 29323929323924923592352353; done
}
# <enddbg:run>

cd "$install_path" || {
  mkdir -p "$install_path"
  cd "$install_path"
}

[ -d "bin" ] && run_system || bootstrap_system
