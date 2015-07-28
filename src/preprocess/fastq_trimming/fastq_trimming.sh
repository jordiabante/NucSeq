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

TEMP=$(getopt -o hd:l: -l help,outdir:,length: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ] 
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir="$PWD"
readLength=50

while true
do
  case "$1" in
    -h|--help)
      cat "$script_absdir"/${script_name}_help.txt
      exit
      ;;  
    -d|--outdir)
      outdir=$2
      shift 2
      ;;  
    -l|--length)
      readLength=$2
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

# Read input
inputFile=$1
prefix="${inputFile%.*}"
outfile="${outdir}/${prefix}_trim${readLength}.fastq.gz"

# Run
  zcat "$inputFile" | \
    awk -v readLength="$readLength" '{if(NR%2!=0){print $0}else{print substr($0,0,readLength)}}' | \
    gzip > "$outfile"

