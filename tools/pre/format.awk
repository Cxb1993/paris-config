function format_nxt(r,   tok) {
    match(LINE, "^" r)
    tok = substr(LINE, 1, RLENGTH)
    LINE   = substr(LINE, 1 + RLENGTH)
    return tok
}

function format_set(f,  d, w, base, digits, ch, E, FMT) { # [s]et [f]ormat; format like fortran!
    # [base][w].[d]e[E]
    # w: the number of characters to use
    # d: the number of digits to the right of the decimal point
    # E: the number of digits in the exponent
    # base: base of the format `I' or `es'
    # sets format_FMT (printf format string) and E
    digits = "[0-9]*"
    ch = "[a-zA-Z]+" # characters

    LINE = f
    BASE = format_nxt(ch)
    if (BASE == "I") {
	w = format_nxt(digits)
	FMT = "%" w "d"; E = -1
    } else if (BASE == "es") {
	w = format_nxt(digits); format_nxt("\\.")
	d = format_nxt(digits)
	format_nxt("[eE]")
	E   = format_nxt(digits)
	w = w - E + 2 # space for bigger `E'
	FMT = "%" w "." d "E"
    } else {
	die("format " f " is not supported")
    }

    format_E = E
    format_FMT = FMT
}

function format_print(e,   m, i, a, b, E) { # print number
    E = format_E
    e = sprintf(format_FMT, e)
    if (E == 2 || E == -1)  return e
    if (!match(e, /E[+-]/)) return e

    # add or remove digits from exponent 1.0e+02 -> 1.0e+002
    a = substr(e, 1, RSTART + RLENGTH - 1)
    b = substr(e, RSTART + RLENGTH) # split e into (a b)

    b = "0000000" b
    b = substr(b, length(b) - E + 1)
    return a b
}
