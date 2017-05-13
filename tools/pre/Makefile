FC=gfortran
FCFLAGS=-Wall -Wextra -g -O0

%: %.f90; $(FC) $(FCFLAGS) $< -o $@
format: format.f90

.PHONY: clean
clean:; rm -rf format
