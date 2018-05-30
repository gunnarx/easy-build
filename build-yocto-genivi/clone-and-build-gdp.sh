#!/bin/bash

# Sample script to build GDP from sources

# Define variable with the given default value
# unless av value was already passed in environment
deref() { eval echo \$$1 ; }
set_default() {
  var_name=$1
  default="$2"
  current_value=$(deref $var_name)
  if [[ -z "$current_value" ]]; then
    eval $var_name="$default"
  fi
}

# Unless already set in environment:
set_default GDP_URL https://github.com/GENIVI/genivi-dev-platform.git
set_default GDP_BRANCH master
set_default MACHINE qemux86-64
set_default IMAGE_TARGET genivi-dev-platform

# Working dirs, depnding on if it's a bind-mounted dir in container or not.
if [ -d /host_workdir ] ; then
  # Host work dir has been mounted, let's use that
  WORKDIR=/host_workdir/genivi-dev-platform
else
  WORKDIR=/home/build/genivi-dev-platform
fi

[ "$GDP_SHA" != "" ] && WORKDIR=$WORKDIR-$GDP_SHA

# In case a directory is being reused we will be building the wrong
# sources if the git-clone is simply skipped.  Instead reset
# it to the given fork/branch/whatever, which might have changed
if [ -e "$WORKDIR" ]; then 
  cd "$WORKDIR" && \
    git remote set-url origin "$GDP_URL" && \
    git fetch origin && \
    git reset --hard && \
    git checkout origin/$GDP_BRANCH

else
  # Empty, so just do a fresh checkout
  git clone -b $GDP_BRANCH $GDP_URL $WORKDIR
fi

cd "$WORKDIR"
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
bitbake $IMAGE_TARGET

# EOF
