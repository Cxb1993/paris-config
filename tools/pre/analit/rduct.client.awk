function main(  a, b, c, n, m, ylo, yhi, zlo, zhi, i, j, y, z) {
    c1 = -1 # a pressure gradient parameter, (dp/dx)/(mu/gc)
	    # dynamic viscosity, mu
    b = 0.5; a = 0.5
    rduct_ini(b, a, c1)
    
    n = m = 30

    ylo = -b; yhi = b # a cross section of a rectangular duct
    zlo = -a; zhi = a

    for (i = 0; i < n; i++) {
	if (i > 0) printf "\n"
	for (j = 0; j < m; j++) {
	    y = ylo + (yhi - ylo)/(n - 1) * i
	    z = zlo + (zhi - zlo)/(m - 1) * j
	    print y, z, rduct(y, z)
	}
    }
}

BEGIN { main() }
