function b_nxt(r,   tok) {
    match(LINE, "^" r)
    tok = substr(LINE, 1, RLENGTH)
    LINE   = substr(LINE, 1 + RLENGTH)
    return tok
}

function sf(f,  d, w, base, digits, ch) { # [s]et [f]ormat; format like fortran!
    # d: the number of digits to the right of the decimal point
    # w: the number of characters to use
    # E: the number of digits in the exponent
    # base: base of the format `I' or `es'

    # sets FMT (printf format string) and E
    digits = "[0-9]*"
    ch = "[a-zA-Z]+" # characters

    LINE = f
    BASE = b_nxt(ch)
    if (BASE == "I") {
	w = b_nxt(digits)
	FMT = "%" w "d"; E = -1
    } else if (BASE == "es") {
	w = b_nxt(digits); b_nxt("\\.")
	d = b_nxt(digits)
	b_nxt("[eE]")
	E   = b_nxt(digits)
	w = w - E + 2 # space for bigger `E'
	FMT = "%" w "." d "E"
    } else {
	die("format " f " is not supported")
    }
}

function pn(e,   m, i, a, b) { # print number
    e = sprintf(FMT, e)
    if (E == 2 || E == -1)  return e
    if (!match(e, /E[+-]/)) return e

    # add or remove digits from exponent 1.0e+02 -> 1.0e+002
    a = substr(e, 1, RSTART + RLENGTH - 1)
    b = substr(e, RSTART + RLENGTH) # split e into (a b)

    b = "0000000" b
    b = substr(b, length(b) - E + 1)
    return a b
}
