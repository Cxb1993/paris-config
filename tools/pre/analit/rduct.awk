#!/usr/bin/awk -f

BEGIN {
    pi = 3.141592653589793
    c1 = -1 # a pressure gradient parameter, (dp/dx)/(mu/gc)
	    # dynamic viscosity, mu
    b = 0.5; a = 0.5
    n = m = 30

    ylo = -b; yhi = b # a cross section of a rectangular duct
    zlo = -a; zhi = a

    for (i = 0; i < n; i++) {
	for (j = 0; j < m; j++) {
	    y = ylo + (yhi - ylo)/(n - 1) * i
	    z = zlo + (zhi - zlo)/(m - 1) * j
	    print y, z, f(y, z)
	}
	printf "\n"
    }
}

function f(y, z,    z0, y0, b0,   n, nm,   s, A, e0, e1, e2) {
    nm = 50 # number of elements in a seria
    z0 = z*pi/(2*a)
    y0 = y*pi/(2*a)
    b0 = b*pi/(2*a)
    A  = -16*c1*a^2/pi^3
    for (n = 1; n <= nm; n += 2) {
	e0 =  1/n^3 * (-1)^( (n-1)/2 )
	e1 =  1 - cosh(n*y0)/cosh(n*b0)
	e2 =  cos(n*z0)
	s += e0 * e1 * e2
    }
    return A*s
}

function cosh(x) {
    if (x < 0) x = - x
    if (x > 21) return exp(x)/2
    return (exp(x) + exp(-x))/2
}
