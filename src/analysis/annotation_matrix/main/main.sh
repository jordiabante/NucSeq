#/usr/bin/env bash
rm -rf out
../annotation_matrix.sh -t 4 -d out/ -- input/input_in_reference.cff.gz
