Exporting to git
================

Introduction
------------

Paris uses darcs as a verstion control system. We "bridge" it to git
<https://github.com/slitvinov/paris-git>

install darcs
-------------


	sudo apt-get install cabal-install
	cabal install darcs


incremental export
------------------

<http://darcs.net/Using/Convert>

	export PATH=$HOME/.cabal/bin:$PATH
	darcs get http://www.ida.upmc.fr/~zaleski/darcs/paris-devel
	cd paris-devel
	git init ../paris-git
	touch ../paris-git/git.marks
	darcs convert export --read-marks darcs.marks --write-marks darcs.marks \
	  | (cd ../paris-git && git fast-import --import-marks=git.marks --export-marks=git.marks)

push to github
--------------

	git push git@github.com:slitvinov/paris-git  master
