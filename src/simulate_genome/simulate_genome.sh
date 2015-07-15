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

TEMP=$(getopt -o hd:c:l:p: -l help,outdir:,chr:,length:,prefix: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ] 
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir="$PWD"
chr=5
length=2000
prefix="simulated_genome"
bases="ACTG"

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
    -c|--chr)
      chr="$2"
      shift 2
      ;;
    -l|--length)
      length="$2"
      shift 2
      ;;
    -p|--prefix)
      prefix="$2"
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

# Output
outfile="${outdir}/${prefix}.fa"

# Outdir
mkdir -p "$outdir"

# Run
for i in `eval echo {1..${chr}}`;
do
  echo ">chr${i}" >> "$outfile"
  random_sequence_generator.sh -l "$length" >> "$outfile"
done

