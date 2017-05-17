#!/usr/bin/awk -f
#
# generate backup files
#
# usage:
# ./pic.awk -f format.awk -f input.awk test_data/input.8.16
# ./pic.awk -f format.awk -f input.awk test_data/input

function arg() {
    dir = ARGV[1]; shift() # output directory
    fi  = ARGV[2]; shift() # input file
}

BEGIN {
    fo_fmt = "%s/backup_%05d"
    arg()
    time = itimestep = 0

    X = 1; Y = 2; Z = 3

    input_ini()
    input(fi)

    # use conventions from the code
    nPx = INPUT["npx"]; nPy = INPUT["npy"]; nPz = INPUT["npz"]
    Nx = INPUT["Nx"]; Ny = INPUT["Ny"]; Nz = INPUT["Nz"]
    Ng = INPUT["Ng"]

    xLength = INPUT["XLENGTH"]
    yLength = INPUT["YLENGTH"]
    zLength = INPUT["ZLENGTH"]

    mu   = INPUT["MU1"]
    dpdx = INPUT["dPdX"]
    Mx = Nx/nPx; My = Ny/nPy; Mz = Nz/nPz
    n[X] = Mx; n[Y] = My; n[Z] = Mz

    for (coords[X] = 0; coords[X] < nPx; coords[X]++)
    for (coords[Y] = 0; coords[Y] < nPy; coords[Y]++)
    for (coords[Z] = 0; coords[Z] < nPz; coords[Z]++) {
	is = coords[X]*n[X] + 1 + Ng
	js = coords[Y]*n[Y] + 1 + Ng
	ks = coords[Z]*n[Z] + 1 + Ng

	ie = is + n[X] - 1
	je = js + n[Y] - 1
	ke = ks + n[Z] - 1

	imin = is - Ng
	jmin = js - Ng
	kmin = ks - Ng

	imax = ie + Ng
	jmax = je + Ng
	kmax = ke + Ng

	set_u() # uses [ijk][min|max]

	write(sprintf(fo_fmt, dir, iproc++))
    }
}

function write(f) {
    write_header(f)
    write_vof(f)
    close(f)
}

function set_u(   i, j, k, y0, u0) {
    rduct_ini(yLength/2, zLength/2, dpdx/mu)  # initialize analytical profile
    for (k = ks; k <= ke; k++) for (j = js; j <= je; j++) {
       y0 = y(j); z0 = z(k)
       u0 = rduct0(y0, z0)
       for (i = is; i <= ie; i++) u[i,j,k] = u0
    }
}

function write_header(f,   l) {
    # time,itimestep,imin,imax,jmin,jmax,kmin,kmax
    format_set("es17.8e3")
    l = l pn(time)
    format_set("I10")
    l = l pn(itimestep) pn(imin) pn(imax) pn(jmin) pn(jmax) pn(kmin) pn(kmax)
    print l > f
}

function write_vof(f,   i, j, k,   l) {
    for (k=kmin; k<=kmax; k++) for (j=jmin; j<=jmax; j++) for (i=imin; i<=imax; i++) {
       format_set("es25.16e3")
       l = pn(u[i,j,k]) pn(v[i,j,k]) pn(w[i,j,k]) pn(p[i,j,k]) pn(cvof[i,j,k])
       print l > f
    }
}

function pn(s) { return format_print(s) } # [p]rint [n]umber
function  z(i) { return  (i - Ng - 1/2)*zLength/Nz }
function  y(i) { return  (i - Ng - 1/2)*yLength/Ny }

function shift(  i) { for (i = 2; i < ARGC; i++) ARGV[i-1] = ARGV[i]; ARGC-- }
