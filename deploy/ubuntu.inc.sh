install_openmpi () (
    force_cd "$PARIS_ROOT/3rd"
    msg 'openmpi(3rd):' `pwd`
    va=2.0 vb=1 # major and minor versions
    d=https://www.open-mpi.org/software/ompi/v${va}/downloads
    f=openmpi-${va}.${vb}.tar.gz
    curl -O -s $d/$f
    tar zxf       $f
    cd openmpi-${va}.${vb}
    msg 'openmpi(src):' `pwd`
    msg 'openmpi(pre):' "$PARIS_PREFIX/openmpi"
    opt="--enable-mpi-fortran --disable-java --disable-dlopen"
    ./configure --prefix="$PARIS_PREFIX/openmpi" $opt > /dev/null
    make -j8                                          > make.log
    make install                                      > make.install.log
)

install_vofi () (
    force_cd "$PARIS_ROOT/3rd"
    msg 'vofi(3rd):' `pwd`
    v=1.0
    d=http://www.ida.upmc.fr/~zaleski/paris
    f=Vofi-${v}.tar.gz
    curl -s -O $d/$f
    tar zxf       $f
    cd Vofi
    msg 'vofi(src):' `pwd`
    msg 'vofi(pre):' "$PARIS_PREFIX/vofi"
    ./configure --prefix="$PARIS_PREFIX/vofi" > /dev/null
    make                                      > make.log # fails in parallel
    make install                              > make.install.log
)

install_hypre () (
    force_cd "$PARIS_ROOT/3rd"
    msg 'hypre(3rd):' `pwd`
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
    msg 'silo(3rd):' `pwd`
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

clone_paris () (
    force_cd "$PARIS_ROOT"
    check_dir paris
    msg 'paris(git):' "$PARIS_ROOT/paris"
    git clone git://github.com/slitvinov/paris-git paris
)

install_tools () {
    (cd tools/wparis     && make install BIN="$PARIS_BIN")
    (cd tools/pre        && make install BIN="$PARIS_BIN")
    (cd tools/pre/analit && make install BIN="$PARIS_BIN")
}
