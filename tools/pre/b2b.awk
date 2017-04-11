#!/usr/bin/awk -f

# Read and write backup file
# See `backup_VOF_write' and `backup_VOF_read' functions in paris-git/vofmodules.f90

function read(f,  l, q) {
    getline < f
    # header
    q = 0
    time = $(++q); itimestep = $(++q)
    imin = $(++q); imax = $(++q); jmin = $(++q)
    jmax = $(++q); kmin = $(++q); kmax = $(++q)

    for (k=kmin; k<=kmax; k++) for (j=jmin; j<=jmax; j++) for (i=imin; i<=imax; i++) {
      getline < f		
      q = 0;
      u[i,j,k] = $(++q); v[i,j,k] = $(++q); w[i,j,k] = $(++q)
      p[i,j,k] = $(++q); cvof[i,j,k] = $(++q)
    }
}

function write() {
    printf "  %17.8E\n", 42
}

BEGIN {
    f = ARGV[1]
    read(f)
    write()
}
