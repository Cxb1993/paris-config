#!/bin/bash

# Install paris and third party libraries
install_openmpi () {
    (
	va=2.0 vb=1 # major an minor version
	wget https://www.open-mpi.org/software/ompi/v${va}/downloads/openmpi-${va}.${vb}.tar.gz
	tar zxvf openmpi-${va}.${vb}.tar.gz
	cd openmpi-${va}.${vb}
	./configure --prefix=$HOME/prefix/openmpi --enable-mpi-fortran
	make
	make install
    )
}

install_vofi () {
    (
	v=1.0
	wget http://www.ida.upmc.fr/~zaleski/paris/Vofi-${v}.tar.gz
	tar zxvf Vofi-${v}.tar.gz
	cd Vofi
	./configure --prefix=$HOME/prefix/vofi
	make
	make install
    )
}

install_hypre () {
    (
	v=2.11.1
	wget http://computation.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods/download/hypre-${v}.tar.gz
	tar zxvf hypre-${v}.tar.gz
	cd hypre-${v}/src
	./configure --prefix=$HOME/prefix/hypre
	make
	make install
    )
}

install_silo () {
    (
	v=4.10.2
	wget https://wci.llnl.gov/content/assets/docs/simulation/computer-codes/silo/silo-${v}/silo-${v}.tar.gz
	tar zxvf silo-${v}.tar.gz
	cd silo-${v}
	./configure --prefix=$HOME/prefix/silo
	make
	make install
    )
}

install_paris () {
    git clone git://github.com/slitvinov/paris-git --branch cse
    cd paris-git

    make FLAGS="-O3 -cpp  -fimplicit-none" \
	 HAVE_VOFI=1 HAVE_SILO=1 \
	 SILO_DIR=$HOME/prefix/silo \
	 HYPRE_DIR=$HOME/prefix/hypre/lib \
	 VOFI_DIR=$HOME/prefix/vofi/lib
}

install_tools () {
    (cd tools/wparis ; ./install.sh)
    (cd tools/bubbles; ./install.sh)
}

mkdir -p paris-src
cd       paris-src

#install_openmpi
#export PATH=$HOME/prefix/openmpi/bin:$PATH

install_vofi &&
    install_hypre &&
    install_silo &&
    install_paris &&
    install_tools
