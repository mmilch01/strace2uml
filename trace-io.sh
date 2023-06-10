# Author: Mikhail Milchenko, mmilchenko@wustl.edu
# Copyright (c) 2023, Computational Imaging Research Center  
# Washington University in Saint Louis

# Redistribution and use in source and binary forms,
# with or without modification, are permitted provided 
# that the following conditions are met:

# 1. Redistributions of source code must retain the above 
#    copyright notice, this list of conditions and the following
#    disclaimer.
# 2. Redistributions in binary form must reproduce the above 
#    copyright notice, this list of conditions and the following 
#    disclaimer in the documentation and/or other materials 
#    provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



#!/bin/bash
convert_open_mode() {
    local mode=$1

    # Convert the mode string to an array of mode codes
    declare -A codes=(
        [O_RDONLY]=Read-Only [O_WRONLY]=Write-Only [O_RDWR]=Read-Write
        [O_CREAT]=Create [O_TRUNC]=Truncate [O_APPEND]=Append
        [O_NONBLOCK]=Non-Blocking [O_EXCL]=Exclusive [O_CLOEXEC]=Close-On-Exec
    )

    # Loop through the mode codes and look up the corresponding name
    local mc

    for m in "${!codes[@]}"; do
        if [[ "$mode" == *"$m"* ]]; then
            mc+=("${codes[$m]}")
        fi
    done

    # Remove trailing whitespace and return the result
    printf '%s,' "${mc[@]}" | sed 's/,$//'
}

convert_open_mode1() {
    local mode=$1
    local readable_modes=""

    # Convert the mode string to an array of mode codes
    IFS='|' read -r -a codes <<< "$mode"

    # Loop through the mode codes and look up the corresponding name
    local mc modes=(Read-Only Write-Only Read-Write Create Truncate Append Non-Blocking Exclusive Close-On-Exec)

    for code in "${codes[@]}"; do
        case "$code" in
            "O_RDONLY") readable_modes+="Read-Only ";  mc[0]=YES ;;
            "O_WRONLY") readable_modes+="Write-Only "; mc[1]=YES;;
            "O_RDWR") readable_modes+="Read-Write "; mc[2]=YES;;
            "O_CREAT") readable_modes+="Create "; mc[3]=YES;;
            "O_TRUNC") readable_modes+="Truncate "; mc[4]=YES ;;
            "O_APPEND") readable_modes+="Append "; mc[5]=YES ;;
            "O_NONBLOCK") readable_modes+="Non-Blocking "; mc[6]=YES;;
            "O_DSYNC") readable_modes+="Synchronized_Write " ;;
            "O_SYNC") readable_modes+="Synchronized_Read-Write " ;;
            "O_DIRECTORY") readable_modes+="Directory " ;;
            "O_EXCL") readable_modes+="Exclusive "; mc[7]=YES;;
            "O_NOCTTY") readable_modes+="No_Control-TTY " ;;
            "O_NOFOLLOW") readable_modes+="No_Follow " ;;
            "O_CLOEXEC") readable_modes+="Close-On-Exec "; mc[8]=YES ;;
        esac
    done

    local i mode_codes
    for ((i=0; i<9; i++)); do 
        if [ -z "${mc[i]}" ]; then mc[i]=NO; fi
        if (( i==0 )); then mode_codes=${mc[i]}; else mode_codes=${mode_codes},${mc[i]}; fi
    done

    # Remove trailing whitespace and return the result
#    if [ -n "$readable_modes" ]; then 
#        echo "${readable_modes::-1}"
#    fi
    echo $mode_codes
}

parse_file() {
  local input_file="$1"
  local output_file="$2"

  # Remove any existing output file
  rm -f "$output_file"

  # Write the header line to the output file
  echo "process,timestamp,file,Read-Only,Write-Only,Read-Write,Create,Truncate,Append,Non-Blocking,Exclusive,Close-On-Exec" >> "$output_file"

  # Loop through each line in the input file
  while read -r line; do
    # Check if the line contains "No such file or directory"
    if [[ "$line" == *"No such file or directory"* ]]; then
      continue  # skip this line
    fi

    la=($line)
    # Extract the timestamp, file path, and mode from the line
    process=${la[0]}
    timestamp=${la[1]}
    file=${la[2]#open(\"}; file=${file%%\"*}
    mode=${la[3]%%)}; mode=${mode//|/,}

    # Convert the mode string to an array of mode codes
    declare -A codes=(
        [O_RDONLY]=NO [O_WRONLY]=NO [O_RDWR]=NO [O_CREAT]=NO
        [O_TRUNC]=NO [O_APPEND]=NO [O_NONBLOCK]=NO [O_EXCL]=NO
        [O_CLOEXEC]=NO
    )


    IFS=',' read -r -a modes <<< "$mode"

    for m in "${modes[@]}"; do
        codes["$m"]=YES
    done

    # Write the parsed data to the output file
    printf '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' \
        "$process" "$timestamp" "$file" "${codes[O_RDONLY]}" "${codes[O_WRONLY]}" \
        "${codes[O_RDWR]}" "${codes[O_CREAT]}" "${codes[O_TRUNC]}" \
        "${codes[O_APPEND]}" "${codes[O_NONBLOCK]}" "${codes[O_EXCL]}" \
        "${codes[O_CLOEXEC]}" >> "$output_file"

  done < "$input_file"
  #remove duplicate lines.
  sed -i '$!N; /^\(.*\)\n\1$/!P; D' "$output_file"
}

parse_file1() {
  local input_file="$1"
  local output_file="$2"

  # Remove any existing output file
  rm -f "$output_file"

  echo "timestamp,file,Read-Only,Write-Only,Read-Write,Create,Truncate,Append,Non-Blocking,Exclusive,Close-On-Exec: $mode" >> "$output_file"

  # Loop through each line in the input file
  while read -r line; do
    # Check if the line contains "No such file or directory"
    if [[ "$line" == *"No such file or directory"* ]]; then
      continue  # skip this line
    fi

    # Extract the timestamp  file path  and mode from the line
    timestamp=$(echo "$line" | awk '{print $1}')
    file=$(echo "$line" | awk '{print $2}'); file=${file#*\"}; file=${file%%\"*}
    
    mode=$(echo "$line" | awk '{print $3}'); mode=${mode%)};
    mode=`convert_open_mode $mode`

    # Write the parsed data to the output file
    echo "$timestamp,$file,$mode" >> "$output_file"
  done < "$input_file"
}


# Check that an input script was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <script> <args>"
    exit 1
fi
echo 1
# Run strace on the input script with its arguments  tracing all read and write calls
MAX_STR_SIZE=128 #change this to avoid/reduce abbreviations in output
set -x
/home/mmilchenko/bin/strace -s $MAX_STR_SIZE -tzf -e 'trace=open,execve' -e 'signal=!SIGCHLD' -o strace.log "$@"
#,desc  --trace='!/^/lib.*' strace.log "$@"

set +x

echo parse_file strace.log strace-log.csv
parse_file strace.log strace-log.csv
