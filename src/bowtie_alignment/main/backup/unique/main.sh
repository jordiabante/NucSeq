#!/usr/bin/env bash

GENOME_LENGHT=20
READS_LENGHT=10
START_POINT=1	    # 1 is the 1st nucleotide!
outdir=$PWD
mismatches=1

refGenome="$(randseq.sh -l "$GENOME_LENGHT")"
refGenome2="$(echo "$refGenome$refGenome")"
export BOWTIE_INDEXES="$outdir"
bowtieIndex="$outdir/bowtieIndex"
bowtieIndex2="$outdir/bowtieIndex2"
bowtie2-build -fcq "$refGenome" "$bowtieIndex"
bowtie2-build -fcq "$refGenome2" "$bowtieIndex2"

read_R1="$(echo "$refGenome" | substr.sh -s "$START_POINT"  -l "$READS_LENGHT")"
readMut_R1="$(echo "${read_R1}")"
echo "" | awk -v l="$READS_LENGHT" '{for(i=1;i<=l;i++){printf "A"} print""}'  > quality
echo -e "@SEQ_ID\n"$read_R1"\n+" > "$outdir/read_R1.fastq"
cat quality >> "$outdir/read_R1.fastq" 
gzip read_R1.fastq 	

START_POINT_OFFSET=2 
read_R2="$(echo "$refGenome" | substr.sh -s "$(( $GENOME_LENGHT - $START_POINT - $READS_LENGHT +$START_POINT_OFFSET))"  -l "$READS_LENGHT")"
read_R2="$(revcomp.sh "$read_R2")"
echo -e "@SEQ_ID\n"$read_R2"\n+" > "$outdir/read_R2.fastq"
cat quality >> "$outdir/read_R2.fastq" 
gzip read_R2.fastq 

bowtie2PEuniq1.sh -d "$outdir" -p "_R" -- "$bowtieIndex" read_R1.fastq.gz read_R2.fastq.gz
echo "# --- Input"
echo "Reference Genome: [$refGenome]"
echo "Read 1: [$read_R1]"
echo "Read 2: [$read_R2]"
echo "# --- Output"
bamToSam.sh read.bam
cat read.sam 
bowtie2PEuniq1.sh -d "$outdir" -p "_R" -- "$bowtieIndex2" read_R1.fastq.gz read_R2.fastq.gz
echo "# --- Input"
echo "Reference Genome: [$refGenome2]"
echo "Read 1: [$read_R1]"
echo "Read 2: [$read_R2]"
echo "# --- Output"
bamToSam.sh read.bam
cat read.sam

rm "$outdir"/bowtieIndex* 
rm "$outdir"/*.fastq.gz
rm "$outdir/quality"
rm "$outdir"/*.bam
rm "$outdir"/*.sam
rm "$outdir"/*.log
