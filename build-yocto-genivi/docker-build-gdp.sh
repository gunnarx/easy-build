#!/bin/sh

# ---- SETTINGS ----------------------------------------------------

# If not set in environment, use default:
if [ -z "$HOST_WORK_DIR" ] ; then
  HOST_WORK_DIR="$HOME/easy-build-gdp.$$"
fi

# gmacario or gunnarx
FORK=gunnarx

# -------------------------------------------------------------------

# Set EASYBUILD_INTERACTIVE environment to something to get terminal
# interaction. Otherwise the container detaches
if [ -n "$EASYBUILD_INTERACTIVE" ] ; then
  T=-ti
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

# Build docker container (this will be fast if cached already)
# NOTE that if easy-build itself has updated, you should remove
# this image, so that it gets rebuilt.  
# Like this:
# $ docker rmi easy-build/gdp
docker build -t easy-build/gdp .

mkdir -p "$HOST_WORK_DIR"
chmod 777 "$HOST_WORK_DIR"
uid=$(id -u)
gid=$(id -g)
runcmd="docker run $DETACH $T -u $uid:$gid --name easy-build-gdp --volume "$HOST_WORK_DIR":/host_workdir \
   -e GDP_SHA=$GDP_SHA \
   -e GDP_URL=$GDP_URL \
   -e GDP_BRANCH=$GDP_BRANCH \
   -e MACHINE=$MACHINE \
   easy-build/gdp clone-and-build-gdp.sh"

echo "+ $runcmd"
$runcmd

if [ $? -eq 0 -a -n "$DETACH" ] ; then
  echo Container started successfully
else
  echo Container start failed
fi

