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

TEMP=$(getopt -o ho:t:m: -l help,outdir:,threads:,maxMemory: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir="$PWD"
threads=1
maxMemory="100M"

while true
do
  case "$1" in
    -h|--help)			
      cat "$script_absdir/${script_name}_help.txt"
      exit
      ;;
    -o|--outdir)			
      outdir="$2"
      shift 2
      ;;
    -t|--threads)			
      threads="$2"
      shift 2
      ;;
    -m|--maxMemory)			
      maxMemory="$2"
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

# Read input file
bamInput="$1"
bamName="$(basename "$bamInput")"
bamDir="$(dirname "$bamInput")"

# bedGraph output
bamPrefix="${bamName%.*}"
outfile="${outdir}/${bamPrefix}.sorted"

# Outdir
mkdir -p "$outdir"

# Run
samtools sort -@ "$threads" -m "$maxMemory" "$bamInput" "$outfile"
