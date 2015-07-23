#!/usr/bin/env bash

rm -rf out

../get_fragment_length_distribution.sh -k -d out -- input.bedgraph.gz
