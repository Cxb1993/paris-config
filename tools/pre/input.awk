#!/usr/bin/awk -f

# Parse config file

function conf_ini() {
    BL   = "[\\t ]*" # blank
    NBL  = "[^\\t ]*" # non-blank
    NAME = "[a-zA-Z][_a-zA-Z0-9]*" # fortran name

    STRING = "'[^']*'" # escape `'' ? :TODO:

    I = 0 # index in ORD
}

function skip_comm(l)  { sub(/!.*/, "", l); return l }
function skip_extra(l) { # skip extra lines
    sub("^" BL "&" NAME BL, "", l) # skip group names :TODO:
    sub("^" BL "/" BL, "", l) # skip end of group names '/'
    return l
}

function emptyp(l)    { return l ~ /^[\t ]*$/ }
function zerop(l)     { return length(l) == 0 }
function unblank(l)   { gsub(BL, "", l); return l }
function comma2sep(l) { gsub(/,/, SUBSEP, l); return l}

function nxt(r,   tag) {
    match(LINE, "^" r)
    tag = substr(LINE, 1, RLENGTH)
    LINE   = substr(LINE, 1 + RLENGTH)
    return tag
}

function val_and_type(e) { # return value and set type
    if (e == "T" || e == "F") {IS_LOGICAL = 1;                                     return e}
    if (e ~ STRING)           {IS_STRING  = 1; sub(/^'/, "", e); sub(/'$/, "", e); return e}
    return e
}

function conf_reg(name_idx, val) { # register `val' at CONF
    ORD[I++] = name_idx
    CONF[name_idx] = val
}

function conf0(l_org,  ob, cb, idx, c, i, aval, name, val) { # parse a line
    # `l_org' has the form:
    # bl name bl [(] idx [)] bl = bl ['] val0 [bl val1] [']
    # where  bl: blanks, name: fortran identifier

    IS_ARRAY = IS_STRING = IS_LOGICAL = 0 # global
    LINE = l_org

    nxt(BL); name = nxt(NAME); nxt(BL)
    ob = "\\("; cb = "\\)"
    if (!zerop(nxt(ob))) { # parse x(1,2) = 42
	IS_ARRAY = 1
	idx = nxt("[^)]*") # array indexes
	idx = unblank(idx); idx = comma2sep(idx)
	nxt(cb); nxt(BL)
    }
    nxt("="); nxt(BL)

    for (;;) { # parse x = 1 2 3 4
	c = nxt(NBL)
	if (zerop(c)) break;
	aval[++i] = c
	nxt(BL)
    }
    if (i > 1) {
	IS_ARRAY = 1
	for (i in aval) conf_reg(name SUBSEP i - 1,   val_and_type(aval[i]))
    } else {
	if (zerop(idx)) conf_reg(name,            val_and_type(aval[1]))
	else            conf_reg(name SUBSEP idx, val_and_type(aval[1]))
    }

    ARRAY[name] = IS_ARRAY
    TYPE[name] = \
	IS_STRING  ?   "string" :      \
	IS_LOGICAL ?  "logical" :      \
		       "number"
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
