#!/usr/bin/env bash

GENOME_LENGHT=20
READS_LENGHT=10
START_POINT=1	    # 1 is the 1st nucleotide!
outdir=$PWD
mismatches=1

refGenome="$(randseq.sh -l "$GENOME_LENGHT")"
export BOWTIE_INDEXES="$outdir"
bowtieIndex="$outdir/bowtieIndex"
bowtie2-build -fcq "$refGenome" "$bowtieIndex"

read_R1="$(echo "$refGenome" | substr.sh -s "$START_POINT"  -l "$READS_LENGHT")"
readMut_R1="$(echo "${read_R1}")"
echo "" | awk -v l="$READS_LENGHT" '{for(i=1;i<=l;i++){printf "A"} print""}'  > quality
echo -e "@SEQ_ID\n"$read_R1"\n+" > "$outdir/read_R1.fastq"
echo -e "@SEQ_ID\n"$readMut_R1"\n+" > "$outdir/readMut_R1.fastq"
cat quality >> "$outdir/read_R1.fastq" 
cat quality >> "$outdir/readMut_R1.fastq"
gzip read_R1.fastq readMut_R1.fastq	

START_POINT_OFFSET=2 
read_R2="$(echo "$refGenome" | substr.sh -s "$(( $GENOME_LENGHT - $START_POINT - $READS_LENGHT +$START_POINT_OFFSET))"  -l "$READS_LENGHT")"
read_R2="$(revcomp.sh "$read_R2")"
readMut_R2="$(echo "${read_R2/T/A}")" 
echo -e "@SEQ_ID\n"$read_R2"\n+" > "$outdir/read_R2.fastq"
echo -e "@SEQ_ID\n"$readMut_R2"\n+" > "$outdir/readMut_R2.fastq"
cat quality >> "$outdir/read_R2.fastq" 
cat quality >> "$outdir/readMut_R2.fastq" 
gzip read_R2.fastq readMut_R2.fastq

bowtie2PEuniq1.sh -d "$outdir" -p "_R" -- "$bowtieIndex" read_R1.fastq.gz read_R2.fastq.gz
bowtie2PEuniq1.sh -d "$outdir" -p "_R" -- "$bowtieIndex" readMut_R1.fastq.gz readMut_R2.fastq.gz

echo "# --- Input"
echo "Reference Genome: [$refGenome]"
echo "Read 1: [$read_R1]"
echo "Read 2: [$read_R2]"
echo "# --- Output"
bamToSam.sh read.bam
cat read.sam 
echo "# --- Input"
echo "Reference Genome: [$refGenome]"
echo "Read 1: [$readMut_R1]"
echo "Read 2: [$readMut_R2]"
echo "# --- Output"
bamToSam.sh readMut.bam
cat readMut.sam

rm "$outdir"/bowtieIndex* 
rm "$outdir"/*.fastq.gz
rm "$outdir/quality"
rm "$outdir"/*.bam
rm "$outdir"/*.sam
rm "$outdir"/*.log
