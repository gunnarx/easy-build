#!/bin/sh

# ---- SETTINGS ----------------------------------------------------

HOST_WORK_DIR="$HOME/easy-build-gdp.$$"

# gmacario or gunnarx
FORK=gunnarx

# -------------------------------------------------------------------

# Set EASYBUILD_INTERACTIVE environment to something to get terminal
# interaction. Otherwise the container detaches
if [ -n "$EASYBUILD_INTERACTIVE" ] ; then
  T=-i
  DETACH=
else
  T=
  DETACH=-d
fi

# Are we in the easy-build git repo or is the script by itself?
if ! [ -d .git -a -f clone-and-build-gdp.sh -a -f Dockerfile ] ; then
  # We are not in git-repo...
  # If dir exists, leave it as is, otherwise clone it
  if [ ! -d "easy-build" ] ; then
    set -e
    git clone https://github.com/$FORK/easy-build
  fi
fi

cd easy-build/build-yocto-genivi
docker build -t easy-build/gdp .
mkdir "$HOST_WORK_DIR"
chmod 777 "$HOST_WORK_DIR"
uid=$(id -u)
gid=$(id -g)
runcmd="docker run $DETACH $T -u ${uid}:${gid} --name easy-build-gdp --volume "$HOST_WORK_DIR":/host_workdir easy-build/gdp clone-and-build-gdp.sh"
echo "+ $runcmd"
$runcmd

if [ $? -eq 0 -a -n "$DETACH" ] ; then
  echo Container started successfully
else
  echo Container start failed
fi

