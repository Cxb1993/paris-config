#!/usr/bin/awk -f

function rduct_ini(b, a, c1) {
    # c1: a pressure gradient parameter, (dp/dx)/(mu/gc),
    #     where dynamic viscosity, mu
    #     gc - ?
    rduct_b = b; rduct_a = a; rduct_c1 = c1
}

function rduct0(y, z) { return rduct(y - rduct_b, z - rduct_a) }
function rduct(y, z,    z0, y0, b0,   n, nm,   s, A, e0, e1, e2,   a, b, c, pi) {
    pi = 3.141592653589793
    a = rduct_a; b = rduct_b; c1 = rduct_c1
    
    nm = 50 # number of elements in a seria
    z0 = z*pi/(2*a)
    y0 = y*pi/(2*a)
    b0 = b*pi/(2*a)
    A  = -16*c1*a^2/pi^3
    for (n = 1; n <= nm; n += 2) {
	e0 =  1/n^3 * (-1)^( (n-1)/2 )
	e1 =  1 - rduct_cosh(n*y0)/rduct_cosh(n*b0)
	e2 =  cos(n*z0)
	s += e0 * e1 * e2
    }
    return A*s
}

function rduct_cosh(x) {
    if (x < 0) x = - x
    if (x > 21) return exp(x)/2
    return (exp(x) + exp(-x))/2
}
