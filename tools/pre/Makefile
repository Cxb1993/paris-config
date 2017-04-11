FC=gfortran
FCFLAGS=-Wall -Wextra -g -O0

%: %.f90; $(FC) $(FCFLAGS) $< -o $@
b2b: b2b.f90

.PHONY: clean
clean:; rm -rf b2b
