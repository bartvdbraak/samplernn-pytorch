#!/bin/bash

set -x

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <chunk size in seconds> <preprocess path> <optional: channels:1> <optional: audio bitrate:16k> <optional: audio sampling rate:16000>"
    echo "Example usage: $0 8 techno"
    exit
fi

chunk_size=$1
dataset_path=$2
audio_channels=${3:-1}
audio_bitrate=${4:-16k}
audio_sampling_rate=${5:-16000}

cd preprocess/"${dataset_path}"

for i in *.mp3 *.ogg *.flac *.wav
do
  ffmpeg -i "$i" -ac 1 -ab 16k -ar 16000 "$i.wav"
done

converted="temp.wav"
sox *.wav $converted
cd ../../
mkdir $dataset_path
length=$(ffprobe -i "preprocess/$dataset_path/$converted" -show_entries format=duration -v quiet -of csv="p=0")
end=$(echo "$length / $chunk_size - 1" | bc)
echo "splitting..."
echo $PWD
for i in $(seq 0 $end); do
    ffmpeg -hide_banner -loglevel error -ss $(($i * $chunk_size)) -t $chunk_size -i "preprocess/$dataset_path/$converted" "$dataset_path/$i.wav"
done
echo "done"
rm -f "preprocess/$dataset_path/$converted"