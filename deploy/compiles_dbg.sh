#!/bin/bash

make FLAGS="-O0 -g -cpp  -fimplicit-none" \
     HAVE_VOFI=1 HAVE_SILO=1 \
     SILO_DIR=$HOME/prefix/silo \
     HYPRE_DIR=$HOME/prefix/hypre/lib \
     VOFI_DIR=$HOME/prefix/vofi/lib \
     BINDIR=$HOME/prefix/paris_dbg

