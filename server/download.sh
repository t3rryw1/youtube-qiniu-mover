#!/usr/bin/env bash
if pgrep -c youtube-dl > /dev/null; then
  # echo "Last download task still running, exit"
  exit;
fi

cd $(dirname $0)

git pull

all_file_list=${1:-'../file-list/to-do/to-do-list.txt'}
finished_file_list=${2:-'../file-list/done/downloaded-list.txt'}
printf "Start processing file list...
[$all_file_list] \tas video file list,
[$finished_file_list] \tas the finished file list\n"

#definitions
sorted_all_file_list="tmp/$(basename $all_file_list).tmp"
sorted_finished_file_list="tmp/$(basename $finished_file_list).tmp"

current_task_file_list="tmp/current_task_files.tmp"

sort $all_file_list -u > $sorted_all_file_list
sort $finished_file_list -u > $sorted_finished_file_list

comm -23 $sorted_all_file_list $sorted_finished_file_list > $current_task_file_list

printf "There are $(wc -l < $current_task_file_list) new files to be downloaded\n";
while read url; do
  printf "Start downloading $url\n"
  file_name=$(/usr/local/bin/youtube-dl --get-filename -o "videos/%(upload_date)s/%(uploader)s/%(title)s.%(ext)s" $url)
  if /usr/local/bin/youtube-dl -o "videos/%(upload_date)s/%(uploader)s/%(title)s.%(ext)s" $url ; then
    printf "Finish downloading $url\n"
    printf "Write $url to done List\n"
    printf "$file_name\n" >> $finished_file_list
  else
    printf "Error downloading $url\n"
  fi
done < $current_task_file_list
