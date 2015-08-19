#/usr/bin/env bash

rm -rf out*

../tag_nucleosomes.sh -t 3 -d out -- peaks.cff.gz smooth.cff.gz
