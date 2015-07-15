#!/usr/bin/env bash
shopt -s extglob

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0" .sh)"

if [[ $# -eq 0 ]] && [[ -t 0 ]]
    then
        cat "$script_absdir/${script_name}_help.txt"
        exit 1
fi

TEMP=$(getopt -o h -l help -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults

# Options
while true
do
  case "$1" in
    -h|--help)
      cat "$script_absdir/${script_name}_help.txt"
      exit
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "$script_name.sh:Internal error!" >&2
      exit -1
      ;;
  esac
done

# Command
function cmd_stdin {
"${script_absdir}/python/${script_name}.py"
}

# Check number of arguments
if [ $# -eq 0 ]
then
  # Stdin 
  cmd_stdin 
else
  # Argument found
  printf "%s\n" "$@" | cmd_stdin 
fi

