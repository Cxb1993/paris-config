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

# Install CSE tools
install_tools

clone_paris
