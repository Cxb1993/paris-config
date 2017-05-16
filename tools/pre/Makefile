BIN = $(HOME)/bin
P   = $(HOME)/.paris

PROG = pproc pic
CONF = pproc.awk input.awk pic.awk format.awk

install: install_prog install_conf

install_prog:; mkdir -p $(BIN) && cp $(PROG) $(BIN)
install_conf:; mkdir -p $(P)   && cp $(CONF) $(P)

.PHONY: install install_conf install_prog
