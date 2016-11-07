#!/bin/bash

mpif90 hw.f90 -o hw
mpirun -np 8 ./hw
