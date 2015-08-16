#/usr/bin/env bash

rm -rf out*

../tag_nucleosomes.sh -t 4 -d out -b 21 -- input.cff.gz
../tag_nucleosomes.sh -c -t 4 -d out_collapsed -b 21 -- input.cff.gz
