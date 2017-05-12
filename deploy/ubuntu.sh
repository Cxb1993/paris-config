#!/bin/bash

set -eu


. deploy/ubuntu.inc.sh

# set variables ROOT, PREFIX
set_default

# setup environment for paris (see deploy/ubuntu.inc.sh)
env_paris

# Installing third party libraries
install_openmpi
install_vofi
install_hypre
install_silo

# Install paris
fetch_paris
build_paris
#(clean_paris)

# Install CSE tools
install_tools

# Test paris
test_paris
