#!/usr/bin/env bash

set -f #Disable pathname expansion.
shopt -s extglob
script_name=$(basename "$0" .sh)

TEMP=$(getopt -o hfd:l: -l help,outfilename:,outdir:,length: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ] 
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

abspath_script=$(readlink -f -e "$0")
script_absdir=$(dirname "$abspath_script")
outdir=.
readLength=50

while true
do
  case "$1" in
    -h|--help)
      cat "$script_absdir"/${script_name}_help.txt
      exit
      ;;  
    -f|--outfilename)
      outfilename=x
      shift
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

inputFile=$1
prefix="$(basename.sh "$inputFile" -x '\.fastq.gz')"
outfile="$outdir/"$prefix"_trim"$readLength".fastq.gz"

if [ $outfilename ]
then
	echo "$outfile"
else	
  zcat "$inputFile" | awk -v readLength="$readLength" '{if(NR%2!=0){print $0}else{print substr($0,0,readLength)}}' | gzip > "$outfile"
fi

