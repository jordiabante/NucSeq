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

TEMP=$(getopt -o hd:t:k:b: -l help,outdir:,threads:,kernel:,bandwidth: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ] 
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir="$PWD"
kernel="normal"
bandwidth="75"
threads=2

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
    -t|--threads)
      threads="$2"
      shift 2
      ;;  
    -k|--kernel)
      kernel="$2"
      shift 2
      ;;  
    -b|--bandwidth)
      bandwidth="$2"
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

# Inputs
input="$1"

# Output
input_basename="$(basename "$input")"
prefix="${input_basename%%.*}"
extension="${input_basename#*.}"
outfile="${outdir}/${prefix}_${kernel}${bandwidth}.${extension}"
logfile="${prefix}.log"

# Output directory
mkdir -p "$outdir"

# R script
Rscript "${script_absdir}/R/${script_name}.R"\
    "$input" "$kernel" "$bandwidth" "$threads" 2>>/dev/null\
    | sort -k 1,1 -k 2,2n \
    | groupBy -g 1,2 -c 3 -o sum \
    | gzip > "$outfile"
