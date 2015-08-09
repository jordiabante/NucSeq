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

# Start time
start_time="$(date +"%s%3N")"

# Inputs
input1="$1"
input2="$2"

# Outputs and temp
input1_basename="$(basename "$input1")"
input2_basename="$(basename "$input2")"
input1_prefix="${input1_basename%%.*}"
input2_prefix="${input2_basename%%.*}"
prefix="${input1_prefix}_vs_${input2_prefix}"
tempfile="${outdir}/${prefix}.tmp"
outfile="${outdir}/${prefix}_distribution_analysis.txt"

# Output directory
mkdir -p "$outdir"

# Merge samples
merge.sh -tn -p "$tempfile" -- "$input1" "$input2" &>/dev/null || \
    (echo "Please, clone myutils repository and add it to your PATH variable" && exit 0)

# R command
Rscript "${script_absdir}/R/${script_name}.R" "${tempfile}.txt.gz" "$outfile" &>/dev/null

# Remove temp files
rm -f "${tempfile}.txt.gz"

# Time elapsed
end_time="$(date +"%s%3N")"
echo "Time elapsed: $(( $end_time - $start_time )) ms"

