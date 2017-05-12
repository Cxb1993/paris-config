#!/bin/bash

check_dir () {
    if test ! -d "$1"; then return; fi
    msg  "pwd: " `pwd`
    err  "ERROR: directory \"$1\" already exist"
}

force_cd () {
    mkdir -p "$1"
    cd       "$1"
}

msg () { printf '%s: %s\n' "${prog_name--}" "$*"  1>&2; }
err () { msg "$@"; exit 2; }
