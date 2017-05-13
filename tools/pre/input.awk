#!/usr/bin/awk -f

# Parse config file

function input_ini() {
    INPUT_BL   = "[\\t ]*" # blank
    INPUT_NBL  = "[^\\t ]*" # non-blank
    INPUT_NAME = "[a-zA-Z][_a-zA-Z0-9]*" # fortran name

    INPUT_STRING = "'[^']*'" # escape `'' ? :TODO:

    INPUT_I = 0 # index in ORD
}

function input_skip_comm(l)  { sub(/!.*/, "", l); return l }
function input_skip_extra(l) { # skip extra lines
    sub("^" INPUT_BL "&" INPUT_NAME INPUT_BL, "", l) # skip group names :TODO:
    sub("^" INPUT_BL "/" INPUT_BL, "", l) # skip end of group names '/'
    return l
}

function input_emptyp(l)    { return l ~ /^[\t ]*$/ }
function input_zerop(l)     { return length(l) == 0 }
function input_unblank(l)   { gsub(INPUT_BL, "", l); return l }
function input_comma2sep(l) { gsub(/,/, SUBSEP, l); return l}

function input_nxt(r,   tok) {
    match(INPUT_LINE, "^" r)
    tok = substr(INPUT_LINE, 1, RLENGTH)
    INPUT_LINE   = substr(INPUT_LINE, 1 + RLENGTH)
    return tok
}

function val_and_type(e) { # return value and set type
    if (e == "T" || e == "F") {IS_LOGICAL = 1;                                     return e}
    if (e ~ INPUT_STRING)           {IS_STRING  = 1; sub(/^'/, "", e); sub(/'$/, "", e); return e}
    return e # :TODO: check if it a number
}

function input_reg(name_idx, val) { # register `val' at CONF
    if (name_idx in CONF) input_die("seen " name_idx " before")
    ORD[INPUT_I++] = name_idx
    CONF[name_idx] = val
}

function input_input0(l_org,  ob, cb, idx, c, i, n, aval, name, val, tok) { # parse a line
    # `l_org' has the form:
    # bl name bl [(] idx [)] bl = bl ['] val0 [bl val1] [']
    # where  bl: blanks, name: fortran identifier

    IS_ARRAY = IS_STRING = IS_LOGICAL = 0 # global
    INPUT_LINE = l_org

    input_nxt(INPUT_BL); name = input_nxt(INPUT_NAME); input_nxt(INPUT_BL)
    if (input_zerop(name)) input_die("wrong identifier")
    
    ob = "\\("; cb = "\\)"
    if (!input_zerop(input_nxt(ob))) { # parse x(1,2) = 42
	IS_ARRAY = 1
	idx = input_nxt("[^)]*") # array indexes
	idx = input_unblank(idx); idx = input_comma2sep(idx)
	if (input_zerop(idx)) input_die("emptyp indexes")
	tok = input_nxt(cb);
	if (input_zerop(tok)) input_die("missing )")
	input_nxt(INPUT_BL)
    }
    tok = input_nxt("="); input_nxt(INPUT_BL)
    if (input_zerop(tok)) input_die("missing =")

    for (i = 0;;) { # parse x = 1 2 3 4
	c = input_nxt(INPUT_NBL)
	if (input_zerop(c)) break;
	aval[i++] = c
	input_nxt(INPUT_BL)
    }
    n = i; if (n == 0) input_die("missing RHS")
    if (n > 1) {
	IS_ARRAY = 1
	for (i = 0; i < n; i++) input_reg(name SUBSEP i,   val_and_type(aval[i]))
    } else {
	if (input_zerop(idx)) input_reg(name,            val_and_type(aval[0]))
	else                 input_reg(name SUBSEP idx, val_and_type(aval[0]))
    }

    ARRAY[name] = IS_ARRAY
    TYPE[name] = \
	IS_STRING  ?   "string" :      \
	IS_LOGICAL ?  "logical" :      \
		       "number"
}

function input(f,  l, i) { # sets `CONF', `TYPE' and `ARRAY'
    while (getline l < f > 0) {
	CNT = f ":" ++i # context for error reporting
	l = input_skip_comm(l)
	l = input_skip_extra(l)
	if (input_emptyp(l)) continue
	input_input0(l)
    }
    close(f)
}

function input_die (s) { printf "%s: error: %s\n", CNT, s | "cat 1>&2"; exit 1 }
function input_warn(s) { printf "%s: warning: %s\n", CNT, s | "cat 1>&2"; exit 1 }
