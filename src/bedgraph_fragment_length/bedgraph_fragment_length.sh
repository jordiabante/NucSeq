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

TEMP=$(getopt -o hd:pkf -l help,outdir:,plot,keep,outfilename -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ] 
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir="$PWD"

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
    -p|--plot)
      plot=x
      shift 
      ;;  
    -k|--keep)
      keep=x
      shift 
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
bedgraphFile="$1"
bedgraphName="$(basename "$bedgraphFile")"
bedgraphDir="$(dirname "$bedgraphFile")"

# Output prefix
prefix="${bedgraphName%%.*}"
outfile_txt="${outdir}/${prefix}.txt.gz"
outfile_pdf="${outdir}/${prefix}.pdf"

# Outdir
mkdir -p "$outdir"

# Run
if [[ "$bedgraphFile" =~ \.gz$ ]];
then
  total="$(zcat "$bedgraphFile" | awk 'BEGIN{FS="\t"}{total+=$4}END{print total}')"
  zcat "$bedgraphFile" | awk 'BEGIN{FS="\t";OFS="\t"}{print $3-$2,$4}' | \
    sort -k 1,1n | groupby -g 1 -c 2 -o sum | \
    awk -v total="$total" 'BEGIN{FS="\t";OFS="\t";i=1}\
    {if(i<=500){while(i!=$1){print i,0;i++}print i,$2/total;i++}}' | \
    gzip > "$outfile_txt"
else
  total="$(cat "$bedgraphFile" | awk 'BEGIN{FS="\t"}{total+=$4}END{print total}')"
  cat "$bedgraphFile" | awk 'BEGIN{FS="\t";OFS="\t"}{print $3-$2,$4}' | \
    sort -k 1,1n | groupby -g 1 -c 2 -o sum | \
    awk -v total="$total" 'BEGIN{FS="\t";OFS="\t";i=1}\
    {if(i<=500){while(i!=$1){print i,0;i++}print i,$2/total;i++}}' | \
    gzip > "$outfile_txt"
fi

# Plot using ggplot2
if [ "$plot" ]
then 
  Rscript "$script_absdir"/R/"$script_name".R "$outfile_txt" "$outfile_pdf" && rm "${outdir}/Rplots.pdf"
fi

# Remove the file
if [ ! "$keep" ]
then
  rm "$outfile_txt"
fi
