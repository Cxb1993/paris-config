#!/usr/bin/awk -f

# Convert paris config to python code (loadable with execfile)

BEGIN {
    conf_ini()
    conf(ARGV[1])

    for (i in CONF) {
	n = split(i, a, SUBSEP); name = a[1]
	
	type = TYPE[name]
	if (type == "number")
	    print name, "=", CONF[name]
	else if (type == "string")
	    print name, "=", "'" type "'"
	else if (type == "array") {
	    # do nothing
	}
    }
}
