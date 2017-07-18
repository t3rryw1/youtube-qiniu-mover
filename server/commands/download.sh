#!/usr/bin/env bash
tmp=tmp

sort $1 -u > "tmp/$(basename $1).tmp"
sort $2 -u > "tmp/$(basename $2).tmp"
comm  -23 "tmp/$(basename $1).tmp" "tmp/$(basename $2).tmp" > "tmp/current_files.tmp"

printf "There are $(wc -l < tmp/current_files.tmp) new files to be downloaded\n";
while read url; do
  printf "Start downloading $url\n"
#  file_name=$(youtube-dl --get-filename -o 'videos/%(title)s.%(ext)s' $url)
#  echo $file_name
  youtube-dl -o "videos/%(title)s.%(ext)s" $url
  printf "Finish downloading $url\n"
  printf "Write $url to done List\n"
  printf "$url\n" >> $2
done < tmp/current_files.tmp
