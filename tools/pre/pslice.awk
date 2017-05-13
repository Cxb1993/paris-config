#!/usr/bin/awk -f

# Make a one-dimensional slice of backup files
# Usage:
# ./pslice.awk -f input.awk <input.templ> <backup>...

# tar zxvf zip/np8eq.tar.gz
# ./pslice.awk -f input.awk test_data/np8eq/input test_data/np8eq/backup_0000[0-7]

BEGIN {
    read_input(ARGV[1]); shift();
    i0 = int(Ny*nPy/2); k0 = int(Nz*nPz/2)

    while (ARGC > 1) {
	rbackup(ARGV[1]); shift()
    }
    rbackup_limits()
    write()
}

function read_input(f) {
    input_ini(); input(f)
    nPx = INPUT["npx"]; nPy = INPUT["npy"]; nPz = INPUT["npz"]
    Nx = INPUT["Nx"]; Ny = INPUT["Ny"]; Nz = INPUT["Nz"]
    Ng = INPUT["Ng"]
    xLength = INPUT["XLENGTH"]; yLength = INPUT["YLENGTH"]; zLength = INPUT["ZLENGTH"]
}

function write(   j) {
    for (j = jmin; j <= jmax; j++)
	print y(j), u[i0, j, k0]
}

function yh(j) { return  (j - Ng)      *yLength/Ny }
function  y(j) { return  (j - Ng - 1/2)*yLength/Ny }

function shift(  i) { for (i = 2; i < ARGC; i++) ARGV[i-1] = ARGV[i]; ARGC-- }

# TEST: pslice.t0
# tar zxf zip/np8eq.tar.gz
# ./pslice.awk -f input.awk -f rbackup.awk \
#   test_data/np8eq/input test_data/np8eq/backup_0000[0-7] > \
#   p.out.txt
#
