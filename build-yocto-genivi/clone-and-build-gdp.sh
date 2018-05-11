#!/bin/bash

# Sample script to build GDP from sources

# TEMP some deugging TEMP
pwd
ls -al .
echo whoami
whoami
touch foo

set -e

# Set defaults if not not set in environment
if [ -z "$GDP_URL" ] ; then
   GDP_URL=https://github.com/GENIVI/genivi-dev-platform.git
fi

if [ -z "$GDP_BRANCH" ] ; then
   GDP_BRANCH=master
fi

if [ -z "$MACHINE" ] ; then
   MACHINE=qemux86-64
fi

# Work in bind-mounted dir or inside container?
if [ -d /host_workdir ] ; then
  # Host work dir has been mounted, let's use that
  WORKDIR=/host_workdir/genivi-dev-platform
else
  WORKDIR=/home/build/genivi-dev-platform
fi

[ "$GDP_SHA" != "" ] && WORKDIR=$WORKDIR-$GDP_SHA

if [ ! -e $WORKDIR ]; then git clone -b $GDP_BRANCH $GDP_URL $WORKDIR; fi
cd $WORKDIR 
pwd
ls -al .
echo whoami
whoami
touch foo

git fetch --all --prune
git config user.name "easy-build"
git config user.email "$(whoami)@$(hostname)"

[ "$GDP_SHA" != "" ] && git checkout $GDP_SHA
git show
git status

source init.sh ${MACHINE}
set -x
bitbake genivi-dev-platform

# EOF
