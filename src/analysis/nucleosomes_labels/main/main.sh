#/usr/bin/env bash

rm -rf out

../nucleosomes_cdf.sh -t 4 -d out -- input_pdf.cff.gz
