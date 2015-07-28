#!/usr/bin/env bash

rm -rf out

../fragment_length_distribution.sh -d out -- input.bedgraph.gz
../fragment_length_distribution.sh input.txt
