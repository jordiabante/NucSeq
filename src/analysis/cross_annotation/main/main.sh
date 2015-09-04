#/usr/bin/env bash
rm -rf out
set -x
../cross_annotation.sh -t 4 -d out/ -- input/input.cff.gz reference.gff
