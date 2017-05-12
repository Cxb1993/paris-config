#!/bin/bash

set -eu

. deploy/utils.sh
. deploy/ubuntu.inc.sh
. deploy/.parisrc

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
