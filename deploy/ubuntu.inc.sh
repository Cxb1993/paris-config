install_openmpi () (
    force_cd "$PARIS_ROOT/3rd"
    va=2.0 vb=1 # major and minor versions
    curl -O -s https://www.open-mpi.org/software/ompi/v${va}/downloads/openmpi-${va}.${vb}.tar.gz
    tar zxf openmpi-${va}.${vb}.tar.gz
    cd openmpi-${va}.${vb}
    msg 'openmpi(src):' `pwd`
    msg 'openmpi(pre):' "$PARIS_PREFIX/openmpi"
    opt=--enable-mpi-fortran --disable-java --disable-dlopen
    ./configure --prefix="$PARIS_PREFIX/openmpi" $opt > /dev/null
    make -j8                                          > make.log
    make install                                      > make.install.log
)

install_vofi () (
    force_cd "$PARIS_ROOT/3rd"
    v=1.0
    curl -s -O http://www.ida.upmc.fr/~zaleski/paris/Vofi-${v}.tar.gz
    tar zxf Vofi-${v}.tar.gz
    cd Vofi
    msg 'vofi(src):' `pwd`
    msg 'vofi(pre):' "$PARIS_PREFIX/vofi"
    ./configure --prefix="$PARIS_PREFIX/vofi" > /dev/null 
    make                                      > make.log # fails in parallel
    make install                              > make.install.log
)

install_hypre () (
    force_cd "$PARIS_ROOT/3rd"
    v=2.11.2
    d=https://github.com/LLNL/hypre/archive
    f=v${v}.tar.gz
    curl -s -L -O $d/$f # -L: follow redirect
    tar zxf          $f
    cd hypre-${v}/src
    msg 'hypre(src):' `pwd`
    msg 'hypre(pre):' "$PARIS_PREFIX/hypre"
    ./configure --prefix="$PARIS_PREFIX/hypre" > /dev/null
    make -j8                                   > make.log
    make install                               > make.install.log
)

install_silo () (
    force_cd "$PARIS_ROOT/3rd"
    v=4.10.2
    d=https://wci.llnl.gov/content/assets/docs/simulation/computer-codes/silo/silo-${v}
    f=silo-${v}.tar.gz
    curl -s -O $d/$f
    tar zxf       $f
    cd silo-${v}    
    msg 'silo(src):' `pwd`
    msg 'silo(pre):' "$PARIS_PREFIX/silo"    
    ./configure --prefix="$PARIS_PREFIX/silo" > /dev/null
    make -j8                                  > make.log
    make install                              > make.install.log
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
    force_cd "$TRD"
    cd paris-git
    make_paris clean
)

fetch_paris () (
    force_cd "$ROOT"
    check_dir paris
    git clone git://github.com/slitvinov/paris-git paris
)

test_paris () (
    force_cd "$ROOT"
    cd paris

    touch Tests/BubbleLPP/DONOTRUN

    mkdir -p $PREFIX/paris/bin
    make_paris test
)


install_tools () {
    (cd tools/wparis ; ./install.sh)
    (cd tools/bubbles; ./install.sh)
}
