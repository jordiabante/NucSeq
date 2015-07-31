#/usr/bin/env bash

rm -rf out

../gaussian_kernel_xargs.sh -t 4 -d out -b 150 -- input.cff.gz
