#!/usr/bin/env bash

rm -rf simulated_read_reference_R*

../simulate_sequencing.sh -l 45 -n 5 -- reference.fa
