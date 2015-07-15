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

TEMP=$(getopt -o hd: -l help,outdir: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ] 
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir="$PWD"

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
readFile="$1"
readName="$(basename "$readFile")"
readDir="$(dirname "$readFile")"

# Output prefix
prefix="${readName%%_*}"
outfile="${outdir}/${prefix}_R2.fastq.gz"

# Outdir
mkdir -p "$outdir"

# FASTQ or FASTA
sequence_position=4

# Run
j=3
while read line;
do
  if [ "$j" -eq "$sequence_position" ]
  then
    n="$(reverse_complement.sh "$line")"
    j=1
  else  
    n="$line"
    j="$((j+1))"
  fi
  echo -e "$n"
done < <(zcat -f -- "$readFile") | gzip > "$outfile"

