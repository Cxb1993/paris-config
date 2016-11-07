#!/bin/bash

run () { # use a wrapper (see tools/wparis)
    wparis 8 input.templ
}

np=8 # number of processors
run
