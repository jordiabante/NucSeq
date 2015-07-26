#!/usr/bin/env bash

rm -rf out

../get_fragment_length_distribution.sh -d out -- input.bedgraph.gz
../get_fragment_length_distribution.sh input.txt
