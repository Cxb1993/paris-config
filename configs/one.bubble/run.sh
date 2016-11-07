#!/bin/bash


run () {
    mpirun -np $np paris
}

np=8 # number of processors
run
