#!/usr/bin/awk -f

# Convert paris config to python code (loadable with execfile)

BEGIN {
    conf_ini()
    conf(ARGV[1])

    for (idx in CONF) {
	n = split(idx, a, SUBSEP); name = a[1]
	
	type = TYPE[name]; val = CONF[idx]; array = ARRAY[name]
	if (array) {
	    print type, name, "=", val
	}
    }
}
