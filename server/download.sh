#!/usr/bin/env bash
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  if pgrep -c youtube-dl > /dev/null; then
    exit;
  fi
  qshell=./commands/qshell-linux-x64
elif [[ "$OSTYPE" == "darwin"* ]]; then
  if pgrep youtube-dl > /dev/null; then
    exit;
  fi
  qshell=./commands/qshell-darwin-x64                # Mac OSX
fi

disk_space=$(df | grep -vE '^Filesystem|tmpfs|cdrom' | head -n1 | awk '{ print $4 }')
[ $disk_space -lt "1000000" ] &&  echo "== Low disk_space, aborting. ==" &&  exit;

cd $(dirname $0)

eval $(cat ../.env | xargs)

git pull > /dev/null

youtube_dl=$(command -v youtube-dl)
youtube_dl=${youtube_dl:-$YOUTUBE_DL_PATH}

all_file_list=${1:-'../file-list/to-do/to-do-list.txt'}
finished_file_list=${2:-'../file-list/done/downloaded-list.txt'}
failed_file_list=${3:-'../file-list/done/failed-list.txt'}


echo "Detecting youtube-dl path... in $youtube_dl"

test -z $youtube_dl && echo "Exiting: youtube-dl executable does not exist!" && exit

echo "youtube-dl path: $youtube_dl"

echo "Detecting qshell path..."

test -z $qshell && echo "Exiting: qshell executable does not exist!" && exit

ACCESS_KEY=${ACCESS_KEY:?"Need to set ACCESS_KEY non-empty in .env file"}
SECRET_KEY=${SECRET_KEY:?"Need to set SECRET_KEY non-empty in .env file"}
$qshell account $ACCESS_KEY $SECRET_KEY


if [ ! -f $all_file_list ]; then
  echo "Exiting: Source file list does not exist!" && exit
fi

if [ ! -f $finished_file_list ]; then
  echo "Destination file list does not exist, creating" \
  && touch $finished_file_list
fi

all_file_list=$(realpath  $all_file_list)
finished_file_list=$(realpath  $finished_file_list)
failed_file_list=$(realpath  $failed_file_list)

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

file_name=$(/usr/local/bin/youtube-dl --get-filename -o "%(upload_date)s/%(uploader)s/%(title)s.%(ext)s" -- "$url")
printf "Checking if shell_upload/$file_name exists in bucket ... \n"
if $qshell stat $BUCKET_NAME "shell_upload/$file_name" > /dev/null ; then
  echo "File exists in current bucket, skipping"
  printf "Write $url to done List to skip the file\n"
else
  printf "File shell_upload/$file_name does not exist in bucket\n"
  printf "Start downloading $url\n"
  file_name="videos/$file_name"
  printf "Saving $url to local file \n >> $file_name <<"
  if /usr/local/bin/youtube-dl -o "videos/%(upload_date)s/%(uploader)s/%(title)s.%(ext)s" -- "$url" ; then
    printf "Finish downloading %s\n" $url
    printf "Write %s to done List\n" $url
  else
    printf "Error downloading $url\n remove void video file $file_name\n"
    rm -f "$file_name"
    rm -f "$file_name.part"
    printf "Write $url to failed List and done list to skip the file\n"
    printf "%s\n" $url >> $failed_file_list
  fi
fi
printf "%s\n" $url >> $finished_file_list
