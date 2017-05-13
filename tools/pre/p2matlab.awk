#!/usr/bin/awk -f

# Convert paris config to matlab/octave code

# TEST: p2matlab.t0
# ./p2matlab.awk -f input.awk test_data/input > p.out.m

# TEST: p2matlab.t1
# ./p2matlab.awk -f input.awk  test_data/inputvof  > p.out.m

BEGIN {
    input_ini()
    input(ARGV[1])

    for (i = 0; i in ORD; i++) {
	name_idx = ORD[i]
	name = name_idx; sub(SUBSEP ".*",      "", name)
	type = TYPE[name]; array = ARRAY[name]
	if (array) write_array(type, name)
	else {
	    val = INPUT[name_idx]
	    write_scalar(type, name, val)
	}
    }
}

function write_array(type, name) {
    if (name in ARRAY_DONE) return
    write_array0(type, name)
    ARRAY_DONE[name] # do not come again
}

function write_array0(type, name0,   i, n, name, idx, S, sep, rhs) {
    for (i = 0; i in ORD; i++) {
	name_idx = ORD[i]

	S = SUBSEP
	name = name_idx; sub(S ".*",      "", name)
	if (name != name0) continue

	val = INPUT[name_idx]
	rhs = rhs sep all2m(type, val) # right-hand side (naive with
				       # indexes) :TODO:
	sep = ", "
    }
    rhs = "{" rhs "}" # matlab cell array
    print name0, "=", rhs ";"
}

function write_scalar(type, name, val) {
    print name, "=", all2m(type, val) ";"
}

function all2m(t, v)  {
    if      (t == "number")  return number2m(v)
    else if (t == "logical") return logical2m(v)
    else if (t == "string")  return string2m(v)
    die("unknown type " t)
}

function logical2m(v) { return val == "T" ? "true" : "false" }
function number2m(v)  { sub("d", "e", v); return v }
function string2m(v)  { return "'" v "'" }

function die(s) { msg(s); exit(1) }
function msg(s) { printf "\n(p2matlab.awk) %s\n", s | "cat 1>&2" }
