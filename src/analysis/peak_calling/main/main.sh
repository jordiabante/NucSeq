#/usr/bin/env bash

rm -rf out

../peak_calling.sh -t 4 -d out -- input_smooth.cff.gz
