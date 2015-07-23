#!/usr/bin/env bash

../bowtie_alignment.sh -i 0 -- test_bowtie_alignment.fa \
  simulated_read_test_bowtie_alignment_R1.fastq.gz \
  simulated_read_test_bowtie_alignment_R2.fastq.gz
