#!/usr/bin/awk -f

# split between processors
#
# usage:
# ./ic.awk -f input.awk test_data/input.8.16
# ./ic.awk -f input.awk test_data/input

BEGIN {
    time = itimestep = 0

    X = 1; Y = 2; Z = 3
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

	write_header()
	write_vof()
	exit
    }
}

function write_header(   l) {
    # time,itimestep,imin,imax,jmin,jmax,kmin,kmax
    format_set("es17.8e3")
    l = l pn(time)
    format_set("I10")
    l = l pn(itimestep) pn(imin) pn(imax) pn(jmin) pn(jmax) pn(kmin) pn(kmax)
    print l
}

function write_vof(   i, j, k,   l) {
    for (k=kmin; k<=kmax; k++) for (j=jmin; j<=jmax; j++) for (i=imin; i<=imax; i++) {
       format_set("es25.16e3")
       l = pn(u[i,j,k]) pn(v[i,j,k]) pn(w[i,j,k]) pn(p[i,j,k]) pn(cvof[i,j,k])
       print l
    }
}

function pn(s) {return format_print(s) } # [p]rint [n]umber
