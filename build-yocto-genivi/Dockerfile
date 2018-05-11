# ===========================================================================================
# Project: https://github.com/gmacario/easy-build
#
# Subproject: build-yocto-genivi
#
# Description: Dockerfile for building the Yocto GENIVI Baseline
# and the GENIVI Demo Platform interactively or fully automatic
#
# References:
#   - http://projects.genivi.org/GENIVI_Baselines/meta-ivi/home
#   - https://at.projects.genivi.org/jira/browse/TOOL-21
#
# === SOME COMMON USAGE SCENARIOS ===
#
# --- Build the Docker image ---
# $ docker build -t test/build-yocto-genivi build-yocto-genivi
#
# --- Create a development environment for building YGB and GDP ---
# $ docker run -ti test/build-yocto-genivi
# Then execute /usr/local/bin/clone-and-build-gdp.sh or consult the GENIVI wiki
#
# --- Build GDP storing build results on a separate volume ---
# $ docker run -ti --volume $PWD:/home/build test/build-yocto-genivi /usr/local/bin/clone-and-build-gdp.sh
#
# --- Connect to a running development environment using SSH ---
# $ mkdir /tmp/shared && cd /tmp/shared
# $ mkdir -p .ssh && chmod 700 .ssh
# $ cat ~/.ssh/id_rsa.pub | tee -a .ssh/authorized_keys && chmod 640 .ssh/authorized_keys
# $ docker run -ti -u root -p 5022:22 --volume $PWD:/home/build test/build-yocto-genivi
#   usermod -p verysecret build && service ssh restart
#   ...
#
# From another terminal on the same host
# $ ssh -p 5022 build@localhost

# ===========================================================================================

FROM ubuntu:16.04

MAINTAINER Gianpaolo Macario <gianpaolo_macario@mentor.com>

# Temporary locale - avoids complaint from apt-get
ENV LC_ALL "C"

# Make sure the package repository is up to date
RUN apt-get update

# Install some packages I cannot live without...
RUN apt-get -y install dos2unix git openssh-server screen

# Install the following utilities (required by poky)
RUN apt-get -y install curl make gcc g++ diffstat texinfo gawk chrpath wget libsdl1.2-dev cpio iputils-ping

# Install extra packages (required for building GDP)
RUN apt-get -y install gawk wget git-core diffstat unzip texinfo gcc-multilib \
    build-essential chrpath socat libsdl1.2-dev xterm git-svn

# Make sure the directory exists, otherwise sshd will not start
RUN mkdir -p /var/run/sshd

# Create non-root user that will perform the build of the images
RUN id build 2>/dev/null || useradd --shell /bin/bash build

# Create an empty home dir (so that we can also do bind-mounts)
RUN mkdir /home/build && chown build:build /home/build

RUN mkdir -p /usr/local/bin
COPY clone-and-build-gdp.sh /usr/local/bin/
RUN dos2unix /usr/local/bin/*.sh && chmod 755 /usr/local/bin/*.sh

# Fix error: Please use a locale setting which supports utf-8
# See https://github.com/gmacario/easy-build/pull/260
# Also: https://askubuntu.com/questions/454260/how-to-solve-locale-problem
# The image needs the generation tools and the locale can then be created
RUN apt-get -y install locales
RUN locale-gen en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Expose sshd port
EXPOSE 22

USER build
WORKDIR /home/build
CMD ["/bin/bash"]

# EOF
