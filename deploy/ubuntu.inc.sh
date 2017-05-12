. deploy/utils.sh

set_default () {
    ROOT=$HOME/paris-deploy # where to install paris and third party
			# libraries
    PREFIX=$ROOT/prefix
    SRC=$ROOT/src
    MAKE_FLAGS=-j4         # build in parallel
}

env_paris () { # set env on ubuntu
    opath=$PATH # save an old path
    PATH=$PREFIX/paris/bin:$PATH
    PATH=$PREFIX/openmpi/bin:$PATH
    export PATH
}

install_openmpi () (
    force_cd "$SRC"
    va=2.0 vb=1 # major and minor versions
    curl -O -s https://www.open-mpi.org/software/ompi/v${va}/downloads/openmpi-${va}.${vb}.tar.gz
    tar zxf openmpi-${va}.${vb}.tar.gz
    cd openmpi-${va}.${vb}
    msg 'openmpi(src):' `pwd`
    msg 'openmpi(pre):' "$PREFIX/openmpi"
    
    ./configure --prefix=$PREFIX/openmpi --enable-mpi-fortran --disable-java --disable-dlopen > /dev/null
    make $MAKE_FLAGS                                                                          > make.log
    make install                                                                              > make.install.log
)

install_vofi () (
    force_cd "$SRC"
    v=1.0
    curl -s -O http://www.ida.upmc.fr/~zaleski/paris/Vofi-${v}.tar.gz
    tar zxf Vofi-${v}.tar.gz
    cd Vofi
    msg 'vofi(src):' `pwd`
    msg 'vofi(pre):' "$PREFIX/vofi"
    
    ./configure --prefix="$PREFIX/vofi" > /dev/null 
    make                                > make.log # fails in parallel
    make install                        > make.install.log
)

install_hypre () (
    force_cd "$SRC"
    v=2.11.1
    url=http://computation.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods/download
    wget -q    $url/hypre-${v}.tar.gz
    tar zxf         hypre-${v}.tar.gz
    cd hypre-${v}/src
    msg 'hypre(src):' `pwd`
    msg 'hypre(pre):' "$PREFIX/hypre"

    ./configure --prefix=$PREFIX/hypre > /dev/null
    make $MAKE_FLAGS                   > make.log
    make install                       > make.install.log
)

install_silo () (
    force_cd "$SRC"
    v=4.10.2
    url=https://wci.llnl.gov/content/assets/docs/simulation/computer-codes/silo
    curl -s -O $url/silo-${v}/silo-${v}.tar.gz
    tar zxf silo-${v}.tar.gz
    cd silo-${v}
    
    msg 'silo(src):' `pwd`
    msg 'silo(pre):' "$PREFIX/silo"
    
    ./configure --prefix=$PREFIX/silo > /dev/null
    make $MAKE_FLAGS                  > make.log
    make install                      > make.install.log
)

make_paris() (
    mkdir -p $PREFIX/paris/bin
    make \
	FLAGS="-O3 -g -cpp  -fimplicit-none" \
	HAVE_VOFI=1 HAVE_SILO=1 \
	SILO_DIR=$PREFIX/silo \
	HYPRE_DIR=$PREFIX/hypre/lib \
	VOFI_DIR=$PREFIX/vofi/lib \
	BINDIR=$PREFIX/paris/bin "$@"
)

rc_paris () { # generate rc file
    echo "\
export PREFIX=$PREFIX
export PATH=\$PREFIX/paris/bin:\$PATH
export PATH=\$PREFIX/openmpi/bin:\$PATH
p=\"HAVE_VOFI=1
   HAVE_SILO=1
   SILO_DIR=\$PREFIX/silo
   HYPRE_DIR=\$PREFIX/hypre/lib
   VOFI_DIR=\$PREFIX/vofi/lib
   BINDIR=\$PREFIX/paris/bin\"
d=\"FLAGS=-O0 -g -cpp -fimplicit-none\""
}

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
