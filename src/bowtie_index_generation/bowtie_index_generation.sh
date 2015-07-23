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

TEMP=$(getopt -o h -l help -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

while true
do
  case "$1" in
    -h|--help)
      cat "$script_absdir/${script_name}_help.txt"
      exit
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
reference="$1"
reference_name="$(basename "$reference")"
prefix="${reference_name%.*}"

# Checks BOWTIE2_INDEXES existance
if [ "$BOWTIE2_INDEXES" ];
then
  # Locate BOWTIE2_INDEXES
  outdir="$BOWTIE2_INDEXES"
  outfile="${outdir}/${prefix}"
  # Build the index
  bowtie2-build -fq "$reference" "$outfile"
else
  # Not found
  echo "Environment variable BOWTIE2_INDEXES is not pointing anywhere."
fi
