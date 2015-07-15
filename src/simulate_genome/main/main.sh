#!/usr/bin/env bash
rm test_*
set -x
../simulate_genome.sh -p test_1 -c 2 -l 5
../simulate_genome.sh -p test_2 -c 10 -l 40
