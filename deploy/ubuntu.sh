#!/bin/bash

set -eu
. deploy/ubuntu.inc.sh

paris_env
force_cd "$SRC"
(install_vofi)
(install_hypre)
(install_silo)
(install_paris)
(install_tools)
