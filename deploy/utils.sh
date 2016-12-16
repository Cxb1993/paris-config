#!/bin/bash

check_dir () { # fail if directory exists
    if test ! -d "$1"; then return; fi
    echo "(ERROR) directory \"$1\" already exist" 1>&2
}

force_cd () { # create a directory before `cd'
    mkdir -p "$1"
    cd       "$1"
}
