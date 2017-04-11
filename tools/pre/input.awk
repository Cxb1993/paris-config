#!/usr/bin/awk -f

# Parse config file

function conf_ini() {
    BL   = "[\\t ]*" # blank
    NBL  = "[^\\t ]*" # non-blank
    NAME = "[a-zA-Z][_a-zA-Z0-9]*" # fortran name
}

function skip_comm(l)  { sub(/!.*/, "", l); return l }
function skip_extra(l) { # skip extra lines
    sub("^" BL "&PARAMETERS" BL, "", l)
    sub("^" BL "/" BL, "", l) # there is a line with only '/'
    return l
}

function emptyp(l)    { return l ~ /^[\t ]*$/ }
function zerop(l)     { return length(l) == 0 }
function unblank(l)   { gsub(BL, "", l); return l }
function comma2sep(l) { gsub(/,/, SUBSEP, l); return l}

function nxt(r,   tag) {
    match(L, "^" r)
    tag = substr(L, 1, RLENGTH)
    L   = substr(L, 1 + RLENGTH)
    return tag
}

function conf0(l_org,  ob, cb, idx, c, i, aval, name, val, is_string, is_array, type) { # parse a line
    # `l_org' has the form:
    # bl name bl [(] idx [)] bl = bl ['] val0 [bl val1] [']
    # where  bl: blanks, name: fortran identifier

    L = l_org
    nxt(BL); name = nxt(NAME); nxt(BL)
    ob = "\\("; cb = "\\)"
    if (!zerop(nxt(ob))) { # parse x(1,2) = 42
	is_array = 1
	idx = nxt("[^)]*") # array indexes
	idx = unblank(idx); idx = comma2sep(idx)
	nxt(cb); nxt(BL)
    }
    nxt("="); nxt(BL)

    is_string = !zerop(nxt("'"))
    if (is_string) CONF[name] = nxt("[^']*")
    else {
	for (;;) { # parse also x = 1 2 3 4
	    c = nxt(NBL)
	    if (zerop(c)) break;
	    aval[++i] = c
	    nxt(BL)
	}
	if (i > 1) {
	    is_array = 1
	    for (i in aval) CONF[name, i] = aval[i]
	} else {
	    if (zerop(idx)) CONF[name]             = aval[1]
	    else            CONF[name SUBSEP idx] = aval[1]
	}
    }

    type = \
	is_array  ?   "array" :
	is_string ?  "string" :
		     "scalar"

    CONF[name, "type"] = type
    if (type == "string") print name
}

function conf(f,  l) {
    while (getline l < f > 0) {
	l = skip_comm(l)
	l = skip_extra(l)
	if (emptyp(l)) continue
	conf0(l)
    }
    close(f)
}

BEGIN {
    conf_ini()
    conf(ARGV[1])
}
