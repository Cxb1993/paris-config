#!/usr/bin/awk -f

# split between processor
#
# usage:
# ./proc.awk -f input.awk test_data/input.8.16
# ./proc.awk -f input.awk test_data/input

BEGIN {
    conf_ini()
    conf(ARGV[1])

    # use conventions from the code
    nPx = CONF["npx"]; nPy = CONF["npy"]; nPz = CONF["npz"]
    Nx = CONF["Nx"]; Ny = CONF["Ny"]; Nz = CONF["Nz"]
    Ng = CONF["Ng"]

    xLength = CONF["XLENGTH"]
    yLength = CONF["YLENGTH"]
    zLength = CONF["ZLENGTH"]

    Mx = Nx/nPx; My = Ny/nPy; Mz = Nz/nPz
    n[1] = Mx; n[2] = My; n[3] = Mz

    for (coords[1] = 0; coords[1] < nPx; coords[1]++)
    for (coords[2] = 0; coords[2] < nPy; coords[2]++)
    for (coords[3] = 0; coords[3] < nPz; coords[3]++) {
	is=coords[1]*n[1]+1+Ng; imin=is-Ng
	js=coords[2]*n[2]+1+Ng; jmin=js-Ng
	ks=coords[3]*n[3]+1+Ng; kmin=ks-Ng
	ie = is + n[1] - 1
	je = js + n[2] - 1
	ke = ks + n[3] - 1
	imax = ie + Ng
	jmax = je + Ng
	kmax = ke + Ng

	print imin, imax, jmin, jmax, kmin, kmax
    }
}

# TEST: proc.t0
# ./proc.awk -f input.awk test_data/input.8.16  > t.out.txt
