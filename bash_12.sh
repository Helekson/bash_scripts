#!/bin/bash

usage() {
  echo "Usage: $0 [-s signal] [-e error_file] [-h] process_name"
  echo "  -s signal     Specify the signal number to send (default: 15)"
  echo "  -e error_file Redirect error messages to the specified file"
  echo "  -h            Show this help message"
}

# Default signal to send
signal=15

# Parse options
while getopts "s:e:h" opt; do
  case $opt in
    s)
      signal=$OPTARG
      ;;
    e)
      error_file=$OPTARG
      ;;
    h)
      usage
      exit 0
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

# Shift to process the remaining arguments
shift $((OPTIND - 1))

# Check if process name is provided
if [ $# -eq 0 ]; then
  echo "Error: Process name is required"
  usage
  exit 1
fi

process_name=$1

# Find PIDs of the processes with the given name
pids=$(pgrep "$process_name")

# If no processes found, output an error
if [ -z "$pids" ]; then
  echo "Error: No processes found with the name '$process_name'"
  [ -n "$error_file" ] && echo "No processes found" >> "$error_file"
  exit 1
fi

# Send the signal to each process
for pid in $pids; do
  if ! kill -$signal $pid 2>/dev/null; then
    echo "Error: Failed to kill process $pid"
    [ -n "$error_file" ] && echo "Failed to kill process $pid" >> "$error_file"
  else
    echo "Sent signal $signal to process $pid"
  fi
done
