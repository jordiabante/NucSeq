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

TEMP=$(getopt -o ho: -l help,outdir: -n "$script_name.sh" -- "$@")

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
      cat "$script_absdir/${script_name}_help.txt"
      exit
      ;;
    -o|--outdir)			
      outdir="$2"
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
bamPrefix="${bamName%%.*}"
outfile="${outdir}/${bamPrefix}.bedGraph.gz"

# Outdir
mkdir -p "$outdir"

# Run
samtools view "$bamInput" | \
  awk 'BEGIN{FS="\t";OFS="\t"} !/^@/ {if($8>$4){print $3,$4,$6+$8,1}}' |\
  sort -k 1,1 -k 2,2n -k 3,3n | \
  groupby -g 1,2,3 -c 4 -o sum | \
  gzip > "$outfile"
