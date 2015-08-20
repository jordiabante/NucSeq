#!/usr/bin/env bash
shopt -s extglob

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0" .sh)"

# Find perl scripts
perl_script="${script_absdir}/perl/${script_name}.pl"

if [ $# -eq 0 ]
    then
        cat "$script_absdir/${script_name}_help.txt"
        exit 1
fi

TEMP=$(getopt -o hd:t: -l help,outdir:,threads: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ] 
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir="$PWD"
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
input="$1"

# Output
input_basename="$(basename "$input")"
prefix="${input_basename%%_smooth.*}"
extension="${input_basename#*.}"
tempfile="${outdir}/${prefix}"
outfile="${outdir}/${prefix}_peaks.${extension}"

# Output directory
mkdir -p "$outdir"

# Export variables
export input
export tempfile
export outfile
export perl_script

# Get chromosomes
chromosomes="$(zcat "$input" | cut -f 1 | uniq)"

# Generate a file for each chromosome
echo "$chromosomes" | xargs -i -n 1 --max-proc "$threads" bash -c \
    'zcat '$input' | grep '{}[[:space:]]' | gzip > '${tempfile}_{}.tmp.gz''

# Call peaks in all the chromosomes
echo "$chromosomes" | xargs -i -n 1 --max-proc "$threads" bash -c \
    ''$perl_script' '${tempfile}_{}.tmp.gz' \
    | gzip > '${tempfile}_{}.done.tmp.gz''

# Concatenate all chromosomes and filter
zcat ${tempfile}_*.done.tmp.gz | sort -k 1,1 -k 2,2n | gzip > "$outfile" 

# Remove temp file
rm -f ${tempfile}*tmp*

# Time elapsed
end_time="$(date +"%s%3N")"
echo "Time elapsed: $(( $end_time - $start_time )) ms"

