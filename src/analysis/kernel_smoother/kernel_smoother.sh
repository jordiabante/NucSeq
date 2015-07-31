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

TEMP=$(getopt -o hd:b: -l help,outdir:,bandwidth: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ] 
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir="$PWD"
bandwidth=150

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
outfile="${outdir}/${prefix}_normal_kernel_bw${bandwidth}.${extension}"
tempfile="${outdir}/${prefix}.tmp"

# Output directory
mkdir -p "$outdir"

# Generate kernel 
"$kernel_smoother" "$bandwidth" >> "$tempfile"

# Apply it to the input file
while read -a line;
do
    # Get midpoint information
    chr=${line[0]}
    pos=${line[1]}
    counts=${line[2]}
    i="$(( $pos - $bandwidth/2 ))"
    # For each point scale the kernel and add it
    while read line;
    do  
        score="$( echo "${line}*${counts}" | bc)"
        printf "%s\t%s\t%s\n" "${chr}" "${i}" "${score}"
        (( i++ ))
    done < "$tempfile"
done < <(zcat -f "$input")  \
    | grep -v "\t0$" \
    | sort -k 1,1 -k 2,2n \
    | groupBy  -g 1,2 -c 3 -o sum \
    | gzip > "$outfile"

# Remove temp file
rm -f "$tempfile"
