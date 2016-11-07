#!/usr/bin/awk -f

# unwrap trajectories

function abs(x) {return x > 0 ? x : -x}

function pp() {
    print
}


BEGIN {
    T = 1; ridx=2
}

NR == 1 {
    p = $(ridx)
    pp()
    next
}

{
    c = $(ridx)
    if      (abs(c + T - p)<abs(c - p)) sh += T
    else if (abs(c - T - p)<abs(c - p)) sh -= T
    $(ridx) = c + sh

    p = c
    pp()
}
