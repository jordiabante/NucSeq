#!/usr/bin/env bash
# ------------------------------------------------------------------
shopt -s extglob

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0" .sh)"

if [ $# -eq 0 ]
    then
        cat "$script_absdir/${script_name}_help.txt"
        exit 1
fi

TEMP=$(getopt -o hd:t:m:x:i: -l help,outdir:,threads:,mismatches:,max_fragment_length:,min_fragment_length: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
threads=2
mismatches=1
min_fragment_length=50
max_fragment_length=250
outdir="$PWD"

# Options
while true
do
  case "$1" in
    -h|--help)			
      cat "$script_absdir/${script_name}_help.txt"
      exit
      ;;
    -d|--outdir)	
      outdir="$2"
      shift 2
      ;;
    -t|--threads)	
      threads="$2"
      shift 2
      ;;
    -m|--mismatches)	
      mismatches="$2"
      shift 2
      ;;
    -x|--max_fragment_length)	
      max_fragment_length="$2"
      shift 2
      ;;
    -i|--min_fragment_length)	
      min_fragment_length="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "$script_name.sh:Internal error!"
      exit 1
      ;;
  esac
done

# Input files
reference="$1"
read1="$2"
read2="$3"

# Find lcp between reads
read_name="$(basename "$read1")"
prefix="${read_name%_*}"

# Get rid of file extension for the reference
reference_name="$(basename "$reference")"
reference="${reference_name%.*}"

# Create output directory if it doesn't already exist
mkdir -p "$outdir"
outfile="${outdir}/${prefix}.bam"
logfile="${outdir}/${prefix}.log"

# Run unique alignment
bowtie2 --local --no-unal --no-mixed --no-discordant --qc-filter -q \
  -I "$min_fragment_length" \
  -X "$max_fragment_length" \
  -N "$mismatches" \
  -p "$threads" \
  -x "$reference" \
  -1 <(zcat "$read1") -2 <(zcat "$read2") 2>"$logfile" \
  | samtools view -Sh - 2>>"$logfile" \
  | grep -v "XS:i:" \
  | samtools view -Sb -@ "$threads" - > "$outfile" 2>>"$logfile"