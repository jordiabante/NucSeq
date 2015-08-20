#/usr/bin/env bash

rm -rf out*

../tag_nucleosomes.sh -t 3 -d out -- input_peaks.cff.gz input_smooth.cff.gz
