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

TEMP=$(getopt -o hd: -l help,outdir: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
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
bam_file="$1"
bam_name="$(basename "$bam_file")"

# bedGraph output
bam_prefix="${bam_name%%.*}"
outfile="${outdir}/${bam_prefix}.cff.gz"

# Outdir
mkdir -p "$outdir"

# Run
bedtools bamtobed -bedpe -i "$bam_file" \
  | awk 'function mid(st,end){if((st+end)%2!=0){x=(st+end+1)/2}else{x=(st+end)/2}fi;return x} \
  BEGIN{FS="\t";OFS="\t"}{print $1,mid($2,$6),1}' \
  | sort -k 1,1 -k 2,2n -k 3,3n \
  | groupby -g 1,2 -c 3 -o sum \
  | gzip > "$outfile"
