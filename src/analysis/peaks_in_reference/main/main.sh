#/usr/bin/env bash

rm -rf out

../peaks_in_reference.sh -t 4 -d out -- input.cff.gz reference.gff
