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
 if pgrep -c youtube-dl; then
   exit;
 fi
 if /usr/local/bin/youtube-dl -o "videos/%(id)s-%(autonumber)s.%(ext)s" $url ; then
   printf "Finish downloading $url\n"
   printf "Write $url to done List\n"
   printf "$url\n" >> $2
 else
   printf "Error downloading $url\n"
 fi
done < tmp/current_files.tmp
