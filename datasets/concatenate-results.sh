#!/bin/bash
#set -x

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <result-folder>"
    echo "Example usage: $0 exp:TEST-frame_sizes:16,4-n_rnn:2-dataset:piano"
    exit
fi

result_folder=$1
cd ../results/"${result_folder}"/samples/

unset wav_files

while IFS= read -r -d '' file; do
   wav_files+=("$file")
done < <(find . -maxdepth 1 -type f -name "*wav" -print0 | sort -V -z)

if (( ${#wav_files[@]} == 0 )); then
   echo "No wav files found"
else
   mkdir output
   sox -e signed-integer "${wav_files[@]}" output/output.wav
fi