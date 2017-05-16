#!/usr/bin/awk -f

# Make a one-dimensional slice of backup files
# Usage:
# ./pslice2.awk -f rbackup.awk -f input.awk <input.templ> <backup>...

# tar zxvf zip/np8cube.tar.gz
# ./pslice2.awk -f rbackup.awk -f input.awk test_data/np8cube/input test_data/np8cube/backup_0000[0-7]

BEGIN {
    read_input(ARGV[1]); shift();
    i0 = int(Ny*nPy/2)

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

function write(   j, k) {
    for (j = jmin; j <= jmax; j++)
    for (k = kmin; k <= kmax; k++)
	print y(j), z(k), u[i0, j, k]
}

function  y(i) { return  (i - Ng - 1/2)*yLength/Ny }
function  z(i) { return  (i - Ng - 1/2)*zLength/Nz }

function shift(  i) { for (i = 2; i < ARGC; i++) ARGV[i-1] = ARGV[i]; ARGC-- }
