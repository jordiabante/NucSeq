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
nucleosomes_pdf="${script_absdir}/perl/${script_name}.pl"

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
peak_file="$1"
smooth_file="$2"

# Output
peak_file_basename="$(basename "$peak_file")"
peak_prefix="${peak_file_basename%%.*}"
peak_temp="${outdir}/${peak_prefix}"
smooth_file_basename="$(basename "$smooth_file")"
smooth_prefix="${smooth_file_basename%%.*}"
smooth_temp="${outdir}/${smooth_prefix}"
kernel_file="${peak_temp}_kernel.tmp"
outfile_prefix="${peak_file_basename%%_peaks*}"
outfile_temp="${outdir}/${outfile_prefix}"
outfile="${outdir}/${outfile_prefix}_tags.cff.gz"

# Output directory
mkdir -p "$outdir"

# Export variables
export peak_file
export smooth_file
export peak_temp
export smooth_temp
export outfile
export outfile_temp
export nucleosomes_pdf

# Get chromosomes
chromosomes="$(zcat "$peak_file" | cut -f 1 | uniq)"

# Generate a file for each chromosome for peak_file
echo "$chromosomes" | xargs -I {} --max-proc "$threads" bash -c \
    'zcat '$peak_file' | grep '{}[[:space:]]' | gzip > '${peak_temp}_{}.tmp.gz''

# Time elapsed
end_time="$(date +"%s%3N")"
echo "Time elapsed after chromosome parsing: $(( $end_time - $start_time )) ms"

# Generate a file for each chromosome for smooth_file
echo "$chromosomes" | xargs -I {} --max-proc "$threads" bash -c \
    'zcat '$smooth_file' | grep '{}[[:space:]]' | gzip > '${smooth_temp}_{}.tmp.gz''

# Time elapsed
end_time="$(date +"%s%3N")"
echo "Time elapsed after chromosome division: $(( $end_time - $start_time )) ms"

# Apply kernel and identify nucleosomes in all the chromosomes
echo "$chromosomes" | xargs -I {} --max-proc "$threads" bash -c \
    ''$nucleosomes_pdf' '${peak_temp}_{}.tmp.gz' '${smooth_temp}_{}.tmp.gz' \
   | gzip > '${outfile_temp}_{}.done.tmp.gz''

# Time elapsed
end_time="$(date +"%s%3N")"
echo "Time elapsed after chromosome tagging nucleosomes: $(( $end_time - $start_time )) ms"

# Concatenate all chromosomes and filter
zcat ${outfile_temp}_*.done.tmp.gz | gzip > "$outfile" 

# Time elapsed
end_time="$(date +"%s%3N")"
echo "Time elapsed after concatenating chromosome files: $(( $end_time - $start_time )) ms"

# Remove temp file
rm -f ${peak_temp}*tmp* ${smooth_temp}*tmp* ${outfile_temp}*tmp*

# Time elapsed
end_time="$(date +"%s%3N")"
echo "Time elapsed after removing temporary files: $(( $end_time - $start_time )) ms"

# Time elapsed
end_time="$(date +"%s%3N")"
echo "Done. Total time elapsed: "$(( $end_time - $start_time ))" ms"
