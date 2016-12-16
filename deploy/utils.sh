#!/bin/bash

check_dir () {
    if test ! -d "$1"; then return; fi
    echo "(ERROR) directory \"$1\" already exist" 1>&1			  
}
