CSE tools for PARIS Simulator [^1]

Setup
=====

Requires fortran, C, and C++ compilers. Test cases require gnuplot [^2]
and visit [^3]


	git clone https://github.com/slitvinov/paris-config
	cd paris-config
	deploy/ubuntu.sh

To customize deploy script comment/uncomment lines in
[file:deploy/ubuntu.sh](deploy/ubuntu.sh) and rerun `deploy/ubuntu.sh`

Footnotes
=========

[^1]: <http://www.ida.upmc.fr/~zaleski/paris/index.html>

[^2]: <http://gnuplot.sourceforge.net>

[^3]: <https://wci.llnl.gov/codes/visit>
