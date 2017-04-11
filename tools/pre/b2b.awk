#!/usr/bin/awk -f

# Read and write backup file
# See `backup_VOF_write' and `backup_VOF_read' functions in paris-git/vofmodules.f90

function read_header(f,   q) {
    getline < f # header
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

function b_nxt(r,   tok) {
    match(LINE, "^" r)
    tok = substr(LINE, 1, RLENGTH)
    LINE   = substr(LINE, 1 + RLENGTH)
    return tok
}

function sf(f,  d, w, base, digits, ch) { # [s]et [f]ormat; format like fortran!
    # d: the number of digits to the right of the decimal point
    # w: the number of characters to use
    # E: the number of digits in the exponent
    # base: base of the format `I' or `es'

    digits = "[0-9]*"
    ch = "[a-zA-Z]+" # characters

    LINE = f
    BASE = b_nxt(ch)
    if (BASE == "I") {
	w = b_nxt(digits)
	FMT = "%" w "d"; E = -1
    } else if (BASE == "es") {
	w = b_nxt(digits); b_nxt("\\.")
	d = b_nxt(digits)
	b_nxt("[eE]")
	E   = b_nxt(digits)
	w = w - E + 2 # space for bigger `E'
	FMT = "%" w "." d "E"
    } else {
	die("format " f " is not supported")
    }
}

function pn(e,   m, i, a, b) { # print number
    e = sprintf(FMT, e)
    if (E == 2 || E == -1)  return e
    if (!match(e, /E[+-]/)) return e

    # add or remove digits from exponent 1.0e+02 -> 1.0e+002
    a = substr(e, 1, RSTART + RLENGTH - 1)
    b = substr(e, RSTART + RLENGTH) # split e into (a b)

    b = "0000000" b
    b = substr(b, length(b) - E + 1)
    return a b
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
