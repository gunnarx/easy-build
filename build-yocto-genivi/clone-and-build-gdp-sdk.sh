#!/bin/bash

D="$(readlink -f "$(dirname "$0")")"

# Override IMAGE_TARGET to select SDK variant.  
# Then delegate the rest to the normal build script
IMAGE_TARGET=genivi-dev-platform-sdk
. $D/clone-and-build-gdp.sh
