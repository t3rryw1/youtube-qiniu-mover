#!/usr/bin/env bash

sort $1 -u > "tmp/$(basename $1).tmp"
sort $2 -u > "tmp/$(basename $2).tmp"
comm  -23 "tmp/$(basename $1).tmp" "tmp/$(basename $2).tmp" > "tmp/current_files.tmp"

printf "There are $(wc -l < tmp/current_files.tmp) new files to be downloaded\n";
printf "" > tmp/current_local_files.tmp
while read url; do
  printf "Start downloading $url\n"
 file_name=$(/usr/local/bin/youtube-dl --get-filename -o "videos/%(upload_date)s/%(uploader)s/%(title)s.%(ext)s" $url)
#  echo $file_name
 if /usr/local/bin/youtube-dl -o "videos/%(upload_date)s/%(uploader)s/%(title)s.%(ext)s" $url ; then
   printf "Finish downloading $url\n"
   printf "Write $url to done List\n"
   printf "$file_name\n" >> "tmp/current_local_files.tmp"
   printf "$url\n" >> $2
 else
   printf "Error downloading $url\n"
 fi
done < tmp/current_files.tmp
