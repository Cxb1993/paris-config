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
	read_backup(ARGV[1]); shift()
    }
    limits()
    write()
}

function write(   j) {
    for (j = jmin; j <= jmax; j++)
	print y(j), u[i0, j, k0]
}

function yh(j) { return  (j - Ng)      *yLength/Ny }
function  y(j) { return  (j - Ng - 1/2)*yLength/Ny }

function limits(   key, i, j, k, a) { # sets [ijk]min, [ijk]max
    imin = jmin = kmin =  1e20
    imax = jmax = kmax = -1e20
    for (key in u) {
	split(key, a, SUBSEP); i = a[1]; j = a[2]; k = a[3]
	imin = min(i, imin); jmin = min(j, jmin); kmin = min(k, kmin)
	imax = max(i, imax); jmax = max(j, jmax); kmax = max(k, kmax)
    }
}

function read_backup(f) {
    read_header(f)
    read_data(f)
}

function read_input(f) {
    input_ini(); input(f)
    nPx = INPUT["npx"]; nPy = INPUT["npy"]; nPz = INPUT["npz"]
    Nx = INPUT["Nx"]; Ny = INPUT["Ny"]; Nz = INPUT["Nz"]
    Ng = INPUT["Ng"]
    xLength = INPUT["XLENGTH"]; yLength = INPUT["YLENGTH"]; zLength = INPUT["ZLENGTH"]
}

function read_header(f,   q) {
    getline < f
    q = 0
    time = $(++q); itimestep = $(++q)
    imin = $(++q); imax = $(++q); jmin = $(++q)
    jmax = $(++q); kmin = $(++q); kmax = $(++q)
}

function read_data(f,  l, q, k, i, j) {
    for (k=kmin; k<=kmax; k++) for (j=jmin; j<=jmax; j++) for (i=imin; i<=imax; i++) {
      getline < f
      q = 0
      u[i,j,k] = $(++q); v[i,j,k] = $(++q); w[i,j,k] = $(++q)
      p[i,j,k] = $(++q); cvof[i,j,k] = $(++q)
    }
}

function shift(  i) { for (i = 2; i < ARGC; i++) ARGV[i-1] = ARGV[i]; ARGC-- }
function max(a, b) { return (a > b) ? a : b }
function min(a, b) { return (a < b) ? a : b }
