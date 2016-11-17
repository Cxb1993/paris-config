#!/bin/bash

set -eu
. deploy/ubuntu.inc.sh

env_paris
# (install_openmpi)
# (install_vofi)
# (install_hypre)
# (install_silo)
(install_paris)
(install_tools)
(test_paris)
