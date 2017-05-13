#!/usr/bin/awk -f

BEGIN {
    input_ini()
    input(ARGV[1])

    nPx = INPUT["npx"]; nPy = INPUT["npy"]; nPz = INPUT["npz"]
    print nPx * nPy * nPz
}
