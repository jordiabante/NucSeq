#/usr/bin/env bash

rm -rf out

../kernel_smoother.sh -d out -b 5 -- input.cff.gz
