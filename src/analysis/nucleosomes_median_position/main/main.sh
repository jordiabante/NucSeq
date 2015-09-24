#/usr/bin/env bash

rm -rf out

../nucleosomes_median_position.sh -t 4 -d out -- input_cdf.cff.gz
