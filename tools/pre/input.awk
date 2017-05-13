#!/usr/bin/awk -f

# Parse config file

function conf_ini() {
    CONF_BL   = "[\\t ]*" # blank
    CONF_NBL  = "[^\\t ]*" # non-blank
    CONF_NAME = "[a-zA-Z][_a-zA-Z0-9]*" # fortran name

    CONF_STRING = "'[^']*'" # escape `'' ? :TODO:

    CONF_I = 0 # index in ORD
}

function conf_skip_comm(l)  { sub(/!.*/, "", l); return l }
function conf_skip_extra(l) { # skip extra lines
    sub("^" CONF_BL "&" CONF_NAME CONF_BL, "", l) # skip group names :TODO:
    sub("^" CONF_BL "/" CONF_BL, "", l) # skip end of group names '/'
    return l
}

function conf_emptyp(l)    { return l ~ /^[\t ]*$/ }
function conf_zerop(l)     { return length(l) == 0 }
function conf_unblank(l)   { gsub(CONF_BL, "", l); return l }
function conf_comma2sep(l) { gsub(/,/, SUBSEP, l); return l}

function conf_nxt(r,   tok) {
    match(CONF_LINE, "^" r)
    tok = substr(CONF_LINE, 1, RLENGTH)
    CONF_LINE   = substr(CONF_LINE, 1 + RLENGTH)
    return tok
}

function val_and_type(e) { # return value and set type
    if (e == "T" || e == "F") {IS_LOGICAL = 1;                                     return e}
    if (e ~ CONF_STRING)           {IS_STRING  = 1; sub(/^'/, "", e); sub(/'$/, "", e); return e}
    return e # :TODO: check if it a number
}

function conf_reg(name_idx, val) { # register `val' at CONF
    if (name_idx in CONF) conf_die("seen " name_idx " before")
    ORD[CONF_I++] = name_idx
    CONF[name_idx] = val
}

function conf_conf0(l_org,  ob, cb, idx, c, i, n, aval, name, val, tok) { # parse a line
    # `l_org' has the form:
    # bl name bl [(] idx [)] bl = bl ['] val0 [bl val1] [']
    # where  bl: blanks, name: fortran identifier

    IS_ARRAY = IS_STRING = IS_LOGICAL = 0 # global
    CONF_LINE = l_org

    conf_nxt(CONF_BL); name = conf_nxt(CONF_NAME); conf_nxt(CONF_BL)
    if (conf_zerop(name)) conf_die("wrong identifier")
    
    ob = "\\("; cb = "\\)"
    if (!conf_zerop(conf_nxt(ob))) { # parse x(1,2) = 42
	IS_ARRAY = 1
	idx = conf_nxt("[^)]*") # array indexes
	idx = conf_unblank(idx); idx = conf_comma2sep(idx)
	if (conf_zerop(idx)) conf_die("emptyp indexes")
	tok = conf_nxt(cb);
	if (conf_zerop(tok)) conf_die("missing )")
	conf_nxt(CONF_BL)
    }
    tok = conf_nxt("="); conf_nxt(CONF_BL)
    if (conf_zerop(tok)) conf_die("missing =")

    for (i = 0;;) { # parse x = 1 2 3 4
	c = conf_nxt(CONF_NBL)
	if (conf_zerop(c)) break;
	aval[i++] = c
	conf_nxt(CONF_BL)
    }
    n = i; if (n == 0) conf_die("missing RHS")
    if (n > 1) {
	IS_ARRAY = 1
	for (i = 0; i < n; i++) conf_reg(name SUBSEP i,   val_and_type(aval[i]))
    } else {
	if (conf_zerop(idx)) conf_reg(name,            val_and_type(aval[0]))
	else                 conf_reg(name SUBSEP idx, val_and_type(aval[0]))
    }

    ARRAY[name] = IS_ARRAY
    TYPE[name] = \
	IS_STRING  ?   "string" :      \
	IS_LOGICAL ?  "logical" :      \
		       "number"
}

function conf(f,  l, i) { # sets `CONF', `TYPE' and `ARRAY'
    while (getline l < f > 0) {
	CNT = f ":" ++i # context for error reporting
	l = conf_skip_comm(l)
	l = conf_skip_extra(l)
	if (conf_emptyp(l)) continue
	conf_conf0(l)
    }
    close(f)
}

function conf_die (s) { printf "%s: error: %s\n", CNT, s | "cat 1>&2"; exit 1 }
function conf_warn(s) { printf "%s: warning: %s\n", CNT, s | "cat 1>&2"; exit 1 }
