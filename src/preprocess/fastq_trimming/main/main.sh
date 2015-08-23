#!/usr/bin/env bash

set -x 
fastq_trimming.sh -l 40
zcat read_R1.fastq.gz | fastq_trimming.sh -l 40
fastq_trimming.sh -l 40 read_R1.fastq.gz 
