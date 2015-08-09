#/usr/bin/env bash
set -x
../cross_annotation.sh -t 4 -d peaks/ -- peaks/input.cff.gz reference.gff
../cross_annotation.sh -t 4 -d smooth/ -- smooth/input.cff.gz reference.gff
