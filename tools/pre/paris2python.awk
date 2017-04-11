#!/usr/bin/awk -f

# Convert paris config to python code (loadable with `execfile' or `import')

BEGIN {
    conf_ini()
    conf(ARGV[1])

    for (i = 1; i in ORD; i++) {
	name_idx = ORD[i]
	n = split(name_idx, a, SUBSEP); name = a[1]
	type = TYPE[name]; array = ARRAY[name]
	if (array) write_array(type, name)
	else {
	    val = CONF[name_idx]
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
    for (i = 1; i in ORD; i++) {
	name_idx = ORD[i]

	S = SUBSEP
	name = name_idx; sub(S ".*",      "", name)
	idx = name_idx; sub("[^" S "]*" S, "", idx)
	if (name != name0) continue
	
	val = CONF[name_idx]	 
	idx = idx2py(idx)
	rhs = rhs sep idx ": " all2py(type, val) # right-hand side
	sep = ", "
    }
    rhs = "{" rhs "}" # python dict
    print name0, "=", rhs
}

function write_scalar(type, name, val) {
    print name, "=", all2py(type, val)
}

function all2py(t, v)  {
    if      (t == "number")  return number2py(v)
    else if (t == "logical") return logical2py(v)
    else if (t == "string")  return string2py(v)
    die("unknown type " t)
}
    
function logical2py(v) { return val == "T" ? "True" : "False" }
function number2py(v)  { sub("d", "e", v); return v }
function string2py(v)  { return "'" v "'" }

function idx2py(v,  cnt) { cnt = gsub(SUBSEP, ", ", v); return cnt ? "(" v ")" : v }

function die(s) { msg(s); exit(1) }
function msg(s) { printf "\n(paris2python.awk) %s\n", s | "cat 1>&2" }
