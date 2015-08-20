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
      outdir=$2
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

# Read input file
bedgraph_file="$1"
bedgraph_name="$(basename "$bedgraph_file")"
bedgraph_dir="$(dirname "$bedgraph_file")"

# Output
prefix="${bedgraph_name%%.*}"
outfile="${outdir}/${prefix}.cff.gz"

# Outdir
mkdir -p "$outdir"

# Command
zcat -f "$bedgraph_file" \
  | awk 'function mid(st,end){if((st+end)%2!=0){x=(st+end+1)/2}else{x=(st+end)/2}fi;return x} \
  BEGIN{FS="\t";OFS="\t"}{print $1,mid($2,$3),$4}' \
  | sort -k 1,1 -k 2,2n \
  | groupBy -g 1,2 -c 3 -o sum \
  | gzip > "$outfile"

