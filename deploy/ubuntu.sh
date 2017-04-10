#!/bin/bash

set -eu

ROOT=$HOME/paris-deploy # where to install paris and third party
			# libraries
PREFIX=$ROOT/prefix
SRC=$ROOT/src
MAKE_FLAGS=-j4         # build in parallel

. deploy/ubuntu.inc.sh

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
