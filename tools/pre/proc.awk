#!/usr/bin/awk -f

# split between processors
#
# usage:
# ./proc.awk -f input.awk test_data/input.8.16
# ./proc.awk -f input.awk test_data/input

BEGIN {
    X = 1; Y = 2; Z = 3
    input_ini()
    input(ARGV[1])

    # use conventions from the code
    nPx = INPUT["npx"]; nPy = INPUT["npy"]; nPz = INPUT["npz"]
    Nx = INPUT["Nx"]; Ny = INPUT["Ny"]; Nz = INPUT["Nz"]
    Ng = INPUT["Ng"]

    xLength = INPUT["XLENGTH"]
    yLength = INPUT["YLENGTH"]
    zLength = INPUT["ZLENGTH"]

    Mx = Nx/nPx; My = Ny/nPy; Mz = Nz/nPz
    n[X] = Mx; n[Y] = My; n[Z] = Mz

    for (coords[X] = 0; coords[X] < nPx; coords[X]++)
    for (coords[Y] = 0; coords[Y] < nPy; coords[Y]++)
    for (coords[Z] = 0; coords[Z] < nPz; coords[Z]++) {
	is=coords[X]*n[X]+1+Ng; imin=is-Ng
	js=coords[Y]*n[Y]+1+Ng; jmin=js-Ng
	ks=coords[Z]*n[Z]+1+Ng; kmin=ks-Ng
	ie = is + n[X] - 1
	je = js + n[Y] - 1
	ke = ks + n[Z] - 1
	imax = ie + Ng
	jmax = je + Ng
	kmax = ke + Ng

	print imin, imax, jmin, jmax, kmin, kmax
    }
}

# TEST: proc.t0
# ./proc.awk -f input.awk test_data/input.8.16  > t.out.txt
