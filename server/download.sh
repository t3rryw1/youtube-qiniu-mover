#!/usr/bin/env bash
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  if pgrep -c youtube-dl > /dev/null; then
    exit;
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  if pgrep youtube-dl > /dev/null; then
    exit;
  fi
fi

cd $(dirname $0)

eval $(cat ../.env | xargs)

git pull > /dev/null

youtube_dl=$(command -v youtube-dl)
youtube_dl=${youtube_dl:-$YOUTUBE_DL_PATH}

all_file_list=${1:-'../file-list/to-do/to-do-list.txt'}
finished_file_list=${2:-'../file-list/done/downloaded-list.txt'}


echo "Detecting youtube-dl path... in $youtube_dl"

test -z $youtube_dl && echo "Exiting: youtube-dl executable does not exist!" && exit

echo "youtube-dl path: $youtube_dl"

if [ ! -f $all_file_list ]; then
  echo "Exiting: Source file list does not exist!" && exit
fi

if [ ! -f $finished_file_list ]; then
  echo "Destination file list does not exist, creating" \
  && touch $finished_file_list
fi

all_file_list=$(realpath  $all_file_list)
finished_file_list=$(realpath  $finished_file_list)

printf "Start processing file list...
Use $all_file_list \tas video file list,
Use $finished_file_list \tas the finished file list\n"


#definitions
sorted_all_file_list="/tmp/$(basename $all_file_list).tmp"
sorted_finished_file_list="/tmp/$(basename $finished_file_list).tmp"

current_task_file_list="/tmp/current_task_files.tmp"

sort $all_file_list -u > $sorted_all_file_list && \
sort $finished_file_list -u > $sorted_finished_file_list && \
comm -23 $sorted_all_file_list $sorted_finished_file_list > $current_task_file_list

lines=$(wc -l < $current_task_file_list)
if [ $lines -eq 0 ]; then
  echo "No new files need downloaded, exit." && exit
fi
read -r url <$current_task_file_list
printf "There are $(wc -l < $current_task_file_list) new files to be downloaded, this task will download \n >> $url <<\n"

printf "Start downloading $url\n"
file_name=$(/usr/local/bin/youtube-dl --get-filename -o "videos/%(upload_date)s/%(uploader)s/%(title)s.%(ext)s" -- "$url")
printf "Saving $url to local file \n >> $file_name <<"
if /usr/local/bin/youtube-dl -o "videos/%(upload_date)s/%(uploader)s/%(title)s.%(ext)s" -- "$url" ; then
  printf "Finish downloading %s\n" $url
  printf "Write %s to done List\n" $url
  printf "%s\n" $url >> $finished_file_list
else
  printf "Error downloading $url\n"
  printf "Still Write $url to done List to skip the file\n"
  printf "%s\n" $url >> $finished_file_list
fi
