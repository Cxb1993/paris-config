#!/bin/bash

# Convert a list of files in stdin to .visit file [1]
# [1] http://visitusers.org/index.php?title=.visit_file

f=/tmp/l2v.$$

cat - > $f
nf=`awk 'END {print NR}' $f` # number of files
echo "!NBLOCKS" $nf
cat $f

rm $f
