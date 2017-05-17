#!/bin/bash

set -eu

. deploy/utils.sh
. deploy/ubuntu.inc.sh
. deploy/.parisrc

# download and install third party libraries
install_openmpi
install_vofi
install_hypre
install_silo

# download and install CSE tools
install_tools

clone_paris
