#!/usr/bin/env bash
shopt -s extglob

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0" .sh)"

TEMP=$(getopt -o hl:r -l help,length:,rna -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ] 
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
length=10
bases="ACTG"

while true
do
  case "$1" in
    -h|--help)
      cat "$script_absdir"/${script_name}_help.txt
      exit
      ;;  
    -l|--length)
      length="$2"
      shift 2
      ;;
    -r|--rna)
      bases="ACUG"
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

# Run
cat /dev/urandom | tr -dc "$bases" | fold -w "$length" | head -n 1
