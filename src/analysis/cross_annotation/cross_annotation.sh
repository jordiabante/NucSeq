#!/usr/bin/env bash
# ------------------------------------------------------------------------------
##The MIT License (MIT)
##
##Copyright (c) 2015 Jordi Abante
##
##Permission is hereby granted, free of charge, to any person obtaining a copy
##of this software and associated documentation files (the "Software"), to deal
##in the Software without restriction, including without limitation the rights
##to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
##copies of the Software, and to permit persons to whom the Software is
##furnished to do so, subject to the following conditions:
##
##The above copyright notice and this permission notice shall be included in all
##copies or substantial portions of the Software.
##
##THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
##IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
##FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
##AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
##LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
##OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
##SOFTWARE.
# ------------------------------------------------------------------------------
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
peaks_file="$1"
reference_file="$2"

# Output
peaks_file_basename="$(basename "$peaks_file")"
reference_file_basename="$(basename "$reference_file")"
peaks_prefix="${peaks_file_basename%%.*}"
reference_prefix="${reference_file_basename%%.*}"
extension="${peaks_file_basename#*.}"
tempfile="${outdir}/${peaks_prefix}"
outfile="${outdir}/${peaks_prefix}_in_${reference_prefix}.${extension}"

# Output directory
mkdir -p "$outdir"

# Export variables
export peaks_file
export reference_file
export tempfile
export outfile
export perl_script

# Get chromosomes
chromosomes="$(zcat "$peaks_file" | cut -f 1 | uniq)"

# Generate a file for each chromosome
echo "$chromosomes" | xargs -I {} --max-proc "$threads" bash -c \
    'zcat '$peaks_file' | grep '{}[[:space:]]' | gzip > '${tempfile}_{}.tmp.gz''

# Cross input with reference for all the chromosomes
echo "$chromosomes" | xargs -I {} --max-proc "$threads" bash -c \
    ''$perl_script' '${tempfile}_{}.tmp.gz' '${reference_file}' \
    | gzip > '${tempfile}_{}.done.tmp.gz'' 

# Concatenate all chromosomes and filter
zcat ${tempfile}_*.done.tmp.gz | sort -k 1,1 -k 2,2n | gzip > "$outfile" 

# Remove temp file
rm -f ${tempfile}*tmp*

# Time elapsed
end_time="$(date +"%s%3N")"
echo "Time elapsed: $(( $end_time - $start_time )) ms"

