#!/usr/bin/env bash
shopt -s extglob

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0" .sh)"

# Find cpp script
kernel_smoother="${script_absdir}/cpp/${script_name}"

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

# Function to apply kernel
function apply_kernel(){
    chr_file="$1";
    zcat -f "$chr_file" | while read -a line;
    do
        # Get midpoint information
        chr=${line[0]};
        pos=${line[1]};
        counts=${line[2]};
        i="$(( $pos - $bandwidth/2 ))";
        cat "$kernel_file" | while read value;
        do
            score="$( echo "${value}*${counts}" | bc)";
            printf "%s\t%s\t%s\n" "${chr}" "${i}" "${score}";
            (( i++ ));
        done
    done
}

# Export function
export -f apply_kernel

# Get chromosomes
chromosomes="$(parallel -j "$threads" 'zcat {} | cut -f 1 | uniq' ::: "$input")"

# Parallel: generate a file for each chromosome
parallel -j "$threads" --env input --env tempfile \
    'zcat '$input' \
    | grep "^{}\t" \
    | gzip > '${tempfile}_{}.tmp.gz'' ::: "$chromosomes"

# Generate kernel 
"$kernel_smoother" "$bandwidth" >> "$kernel_file"

# Parallel: apply kernel to all the chromosomes
parallel -j "$threads" --env tempfile --env apply_kernel \
    'apply_kernel ${tempfile}_{}.tmp.gz \
    | sort -k 2,2n \
    | groupBy -g 1,2 -c 3 -o sum \
    | gzip > '${tempfile}_{}.done.tmp.gz'' ::: "$chromosomes"

# Parallel: concatenate all chromosomes and filter
chr_files="$(ls ${tempfile}*done*)"
parallel -j "$threads" --env outfile \
    'zcat {} \
    | grep -v "\t-" \
    | grep -v "\t0$" \
    | gzip >> "$outfile"' ::: "$chr_files" 

# Remove temp file
rm -f ${tempfile}*tmp*

# Time elapsed
end_time="$(date +"%s%3N")"
echo "Time elapsed: $(( $end_time - $start_time )) ms"

