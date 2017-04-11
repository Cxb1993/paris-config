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

function nxt(r,   tok) {
    match(LINE, "^" r)
    tok = substr(LINE, 1, RLENGTH)
    LINE   = substr(LINE, 1 + RLENGTH)
    return tok
}

function val_and_type(e) { # return value and set type
    if (e == "T" || e == "F") {IS_LOGICAL = 1;                                     return e}
    if (e ~ STRING)           {IS_STRING  = 1; sub(/^'/, "", e); sub(/'$/, "", e); return e}
    return e # :TODO: check if it a number
}

function conf_reg(name_idx, val) { # register `val' at CONF
    ORD[I++] = name_idx
    CONF[name_idx] = val
}

function conf0(l_org,  ob, cb, idx, c, i, n, aval, name, val, tok) { # parse a line
    # `l_org' has the form:
    # bl name bl [(] idx [)] bl = bl ['] val0 [bl val1] [']
    # where  bl: blanks, name: fortran identifier

    IS_ARRAY = IS_STRING = IS_LOGICAL = 0 # global
    LINE = l_org

    nxt(BL); name = nxt(NAME); nxt(BL)
    if (zerop(name)) conf_die("wrong identifier")
    
    ob = "\\("; cb = "\\)"
    if (!zerop(nxt(ob))) { # parse x(1,2) = 42
	IS_ARRAY = 1
	idx = nxt("[^)]*") # array indexes
	idx = unblank(idx); idx = comma2sep(idx)
	if (zerop(idx)) conf_die("emptyp indexes")
	tok = nxt(cb);
	if (zerop(tok)) conf_die("missing )")
	nxt(BL)
    }
    tok = nxt("="); nxt(BL)
    if (zerop(tok)) conf_die("missing =")

    for (i = 0;;) { # parse x = 1 2 3 4
	c = nxt(NBL)
	if (zerop(c)) break;
	aval[i++] = c
	nxt(BL)
    }
    n = i; if (n == 0) conf_die("missing RHS")
    if (n > 1) {
	IS_ARRAY = 1
	for (i = 0; i < n; i++) conf_reg(name SUBSEP i,   val_and_type(aval[i]))
    } else {
	if (zerop(idx)) conf_reg(name,            val_and_type(aval[0]))
	else            conf_reg(name SUBSEP idx, val_and_type(aval[0]))
    }

    ARRAY[name] = IS_ARRAY
    TYPE[name] = \
	IS_STRING  ?   "string" :      \
	IS_LOGICAL ?  "logical" :      \
		       "number"
}

function conf(f,  l, i) {
    while (getline l < f > 0) {
	CNT = f ":" ++i # context for error reporting
	l = skip_comm(l)
	l = skip_extra(l)
	if (emptyp(l)) continue
	conf0(l)
    }
    close(f)
}

function conf_die (s) { printf "%s: error: %s\n", CNT, s | "cat 1>&2"; exit 1 }
function conf_warn(s) { printf "%s: warning: %s\n", CNT, s | "cat 1>&2"; exit 1 }
