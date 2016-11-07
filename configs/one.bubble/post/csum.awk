#!/usr/bin/awk -f

# Compute a cumulative sum of `v_idx' column. Output is in `x_idx'
# column.

BEGIN {
    x_idx = 2
    v_idx = 4
}

function pp() {
    $(x_idx) = x
    print
}

NR == 1 {
    x = 0; tp = $1
    pp()
}

{
    t = $1; dt = t - tp
    vx = $(v_idx); x += vx*dt
    
    tp = t
    pp()
}
