ROOT=$HOME/paris-deploy # where to install paris and third party
			# libraries
PREFIX=$ROOT/prefix
SRC=$ROOT/src

. deploy/utils.sh

env_paris () { # set env on ubuntu
    opath=$PATH # save an old path
    PATH=$PREFIX/paris/bin:$PATH
    PATH=$PREFIX/openmpi/bin:$PATH
    export PATH
}

install_openmpi () (
    force_cd "$SRC"
    va=2.0 vb=1 # major an minor version
    wget https://www.open-mpi.org/software/ompi/v${va}/downloads/openmpi-${va}.${vb}.tar.gz
    tar zxvf openmpi-${va}.${vb}.tar.gz
    cd openmpi-${va}.${vb}
    ./configure --prefix=$PREFIX/openmpi --enable-mpi-fortran
    make
    make install
)

install_vofi () (
    force_cd "$SRC"
    v=1.0
    wget http://www.ida.upmc.fr/~zaleski/paris/Vofi-${v}.tar.gz
    tar zxvf Vofi-${v}.tar.gz
    cd Vofi
    ./configure --prefix=$PREFIX/vofi
    make
    make install
)

install_hypre () (
    force_cd "$SRC"
    v=2.11.1
    wget http://computation.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods/download/hypre-${v}.tar.gz
    tar zxvf hypre-${v}.tar.gz
    cd hypre-${v}/src
    ./configure --prefix=$PREFIX/hypre
    make
    make install
)

install_silo () (
    force_cd "$SRC"
    v=4.10.2
    wget https://wci.llnl.gov/content/assets/docs/simulation/computer-codes/silo/silo-${v}/silo-${v}.tar.gz
    tar zxvf silo-${v}.tar.gz
    cd silo-${v}
    ./configure --prefix=$PREFIX/silo
    make
    make install
)

make_paris() (
    mkdir -p $PREFIX/paris/bin
    make FLAGS="-O3 -g -cpp  -fimplicit-none" \
	 HAVE_VOFI=1 HAVE_SILO=1 \
	 SILO_DIR=$PREFIX/silo \
	 HYPRE_DIR=$PREFIX/hypre/lib \
	 VOFI_DIR=$PREFIX/vofi/lib \
	 BINDIR=$PREFIX/paris/bin "$@"
)

clean_paris () (
    force_cd "$SRC"
    cd paris-git
    make_paris clean
)

fetch_paris () (
    force_cd "$SRC"
    check_dir paris-git
    git clone git://github.com/slitvinov/paris-git --branch cse
)

build_paris() (
    force_cd "$SRC"
    cd paris-git
    mkdir -p $PREFIX/paris/bin
    make_paris
    cd util
    make_paris
    cp rockread $PREFIX/paris/bin
)

test_paris () (
    force_cd "$SRC"
    cd paris-git

    touch Tests/BubbleLPP/DONOTRUN

    mkdir -p $PREFIX/paris/bin
    make_paris test
)


install_tools () {
    (cd tools/wparis ; ./install.sh)
    (cd tools/bubbles; ./install.sh)
}
