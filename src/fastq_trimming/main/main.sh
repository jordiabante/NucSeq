#!/usr/bin/env bash

echo "# --- Input file"
zcat  read_R1.fastq.gz
echo ""
echo "# --- Trimmed file 50"
fastqTrim.sh -- read_R1.fastq.gz
zcat  read_R1_trim50.fastq.gz
echo ""
echo "# --- Trimmed file 25"
fastqTrim.sh -l 25 -- read_R1.fastq.gz
zcat  read_R1_trim25.fastq.gz
echo ""
echo "# --- Trimmed file 5"
fastqTrim.sh -l 5 -- read_R1.fastq.gz
zcat  read_R1_trim5.fastq.gz
