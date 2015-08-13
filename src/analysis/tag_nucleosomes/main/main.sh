#/usr/bin/env bash

rm -rf out

../tag_nucleosomes.sh -t 4 -d out -b 25 -- input.cff.gz
