#!/bin/bash

pre () { # pre-processing (see tools/bubbles)
    b=bubbles/several.inc
    echo "(run.sh) generating: $b"
    rndlines $nb $r | lines2bubbles > "$b"
}

run () { # use a wrapper (see tools/wparis)
    wparis 8 input.templ
}

r=0.125 # bubble radius
np=8 # number of processors
nb=10 # number of of bubbles

pre
run
