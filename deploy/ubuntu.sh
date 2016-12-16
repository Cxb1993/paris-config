#!/bin/bash

set -eu
. deploy/utils.sh
. deploy/ubuntu.inc.sh

# setup environment for paris (see deploy/ubuntu.inc.sh)
env_paris

# Installing third party libraries
(install_openmpi)
(install_vofi)
(install_hypre)
(install_silo)

# Install paris
(install_paris)

# Install CSE tools
(install_tools)

# Test paris
(test_paris)
