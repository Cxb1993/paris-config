#!/usr/bin/awk -f

# Read and write backup file
# See `backup_VOF_write' and `backup_VOF_read' functions in paris-git/vofmodules.f90

function read_header(f,   q) {
    getline < f
    q = 0
    time = $(++q); itimestep = $(++q)
    imin = $(++q); imax = $(++q); jmin = $(++q)
    jmax = $(++q); kmin = $(++q); kmax = $(++q)
}

function read(f,  l, q, k, i, j) {
    for (k=kmin; k<=kmax; k++) for (j=jmin; j<=jmax; j++) for (i=imin; i<=imax; i++) {
      getline < f
      q = 0
      u[i,j,k] = $(++q); v[i,j,k] = $(++q); w[i,j,k] = $(++q)
      p[i,j,k] = $(++q); cvof[i,j,k] = $(++q)
    }
}

function write_header(   l) {
    # time,itimestep,imin,imax,jmin,jmax,kmin,kmax
    sf("es17.8e3")
    l = l pn(time)
    sf("I10")
    l = l pn(itimestep) pn(imin) pn(imax) pn(jmin) pn(jmax) pn(kmin) pn(kmax)
    print l
}

function write_vof(   i, j, k,   l) {
    for (k=kmin; k<=kmax; k++) for (j=jmin; j<=jmax; j++) for (i=imin; i<=imax; i++) {
       sf("es25.16e3")
       l = pn(u[i,j,k]) pn(v[i,j,k]) pn(w[i,j,k]) pn(p[i,j,k]) pn(cvof[i,j,k])
       print l
    }
}

BEGIN {
    f = ARGV[1]
    read_header(f)
    read(f)

    write_header()
    write_vof()
}

function die(s) { msg(s); exit(1) }
function msg(s) { printf "\n(b2b.awk) %s\n", s | "cat 1>&2" }

# TEST: b2b.t0
# awk -f format.awk -f ./b2b.awk test_data/backup_00000 | \
#    head -n 100 > backup.out.txt
