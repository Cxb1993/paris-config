#!/bin/bash

clean () {
    git clean -f -d -x
}

compile () {
    cd ../../
    PATH=`pwd`/util:$PATH
    PATH=$HOME/prefix/paris.openmpi/bin:$PATH
    export PATH
    m () {
      make \
          SILO_DIR=$HOME/prefix/paris \
          HYPRE_DIR=$HOME/prefix/paris/lib \
          HAVE_SILO=1 \
          "$@"
    }

    m
    (cd util && m)
}

run () {
    PATH=$HOME/prefix/paris.openmpi/bin:$PATH
    export PATH
    mpirun -np $np paris
}

(clean)
(compile)
np=8 # number of processors
run

flist () {
    find out_dir/VTK -maxdepth 1 -name 'fields*-*.vtk' | sort -g 
}

flist | xargs -n $np post/vcm.awk | tee ~/t.dat
post/cont.awk ~/t.dat             | tee ~/d.dat
    
# post/vcm.awk out_dir/VTK/fields00010-*.vtk
