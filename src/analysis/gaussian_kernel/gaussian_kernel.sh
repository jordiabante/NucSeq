#!/usr/bin/env bash
shopt -s extglob

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0" .sh)"

# Find other scripts
gaussian_kernel_cpp="${script_absdir}/cpp/${script_name}"
gaussian_kernel_perl="${script_absdir}/perl/${script_name}.pl"

if [ $# -eq 0 ]
    then
        cat "$script_absdir/${script_name}_help.txt"
        exit 1
fi

TEMP=$(getopt -o hd:t:b: -l help,outdir:,threads:,bandwidth: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ] 
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir="$PWD"
bandwidth=150
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

# Start time
start_time="$(date +"%s%3N")"

# Inputs
input="$1"

# Output
input_basename="$(basename "$input")"
prefix="${input_basename%%.*}"
extension="${input_basename#*.}"
tempfile="${outdir}/${prefix}"
kernel_file="${tempfile}_kernel.tmp"
outfile="${outdir}/${prefix}_normal_kernel_bw${bandwidth}.${extension}"

# Output directory
mkdir -p "$outdir"

# Export variables
export input
export tempfile
export kernel_file
export bandwidth
export outfile
export gaussian_kernel_perl

# Get chromosomes
chromosomes="$(zcat "$input" | cut -f 1 | uniq)"

# Generate a file for each chromosome
echo "$chromosomes" | xargs -i -n 1 --max-proc "$threads" bash -c \
    'zcat "$input" | grep {} | gzip > '${tempfile}_{}.tmp.gz''

# Generate kernel 
"$gaussian_kernel_cpp" "$bandwidth" >> "$kernel_file"

# Apply kernel to all the chromosomes
echo "$chromosomes" | xargs -i -n 1 --max-proc "$threads" bash -c \
    '"$gaussian_kernel_perl" "${tempfile}_{}.tmp.gz" "$kernel_file" "$bandwidth" \
    | sort -k 2,2n \
    | groupBy -g 1,2 -c 3 -o sum \
    | gzip > '${tempfile}_{}.done.tmp.gz''

# Concatenate all chromosomes and filter
zcat ${tempfile}_*.done.tmp.gz | sort -k 1,1 -k 2,2n | gzip > "$outfile" 

# Remove temp file
rm -f ${tempfile}*tmp*

# Time elapsed
end_time="$(date +"%s%3N")"
echo "Time elapsed: $(( $end_time - $start_time )) ms"

