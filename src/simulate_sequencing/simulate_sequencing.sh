#!/usr/bin/env bash
shopt -s extglob

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0" .sh)"

if [ $# -eq 0 ]
    then
        cat "$script_absdir/${script_name}_help.txt"
        exit 1
fi

TEMP=$(getopt -o hd:l:n: -l help,outdir:,length:,num_reads: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ] 
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir="$PWD"
length=30
num_reads=10

# Options
while true
do
  case "$1" in
    -h|--help)
      cat "$script_absdir"/${script_name}_help.txt
      exit
      ;;  
    -d|--outdir)
      outdir="$2"
      shift 2
      ;;  
    -l|--length)
      length="$2"
      shift 2
      ;;  
    -n|--num_reads)
      num_reads="$2"
      shift 2
      ;;  
    --) 
      shift
      break
      ;;  
    *)  
      echo "$script_name.sh:Internal error!"
      exit -1
      ;;  
  esac
done

# Read input file
referenceFile="$1"
referenceName="$(basename "$referenceFile")"
referenceDir="$(dirname "$referenceFile")"

# Output prefix
prefix="${referenceName%%.*}"
outfile1="${outdir}/simulated_read_${prefix}_R1.fastq"
outfile2="${outdir}/simulated_read_${prefix}_R2.fastq"

# Outdir
mkdir -p "$outdir"

# Count chromosomes in .fasta file
num_chr="$(cat "$referenceFile" | grep "^>" | wc -l)"
length="$(($length - 1))"

# Run
for i in `eval echo {1..${num_reads}}`;
do
  # Pick a chr randomly
  chr_number="$(shuf -i 1-${num_chr} -n 1)"
  # Store the chr in chr
  chr="$(cat "$referenceFile" | grep -v "^>" | sed -n ${chr_number}p )"
  # Chromosome length
  chr_length="$(echo "$chr" | wc -c)"
  # Start and end R1
  bound="$(($chr_length - $length))"
  start="$(shuf -i 1-${bound} -n 1)"
  end="$((start + $length))"
  # Trim the read and do the complimentary
  read_R1="$(echo "$chr" | cut -c "${start}-${end}")"
  # Start and end R2
  fragment_length="$(shuf -i 80-200 -n 1)"
  end="$(($start + $fragment_length))"
  if [ "$end" -ge "$chr_length" ];
  then
    end="$chr_length"
  fi
  start="$(($end - $length))"
  # Trim the read and do the complimentary
  read_R2="$(echo "$chr" | cut -c "${start}-${end}")"
  read_R2_reverse_complemented="$(reverse_complement.sh "$read_R2")"
  # Print it
  id="@simulated_read_${prefix}:${i}"
  echo -e "${id}\n${read_R1}\n+\nQuality" >> "$outfile1"
  echo -e "${id}\n${read_R2_reverse_complemented}\n+\nQuality" >> "$outfile2"
done

# Compress
gzip "$outfile1" &
gzip "$outfile2"
wait
