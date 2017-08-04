#!/usr/bin/env bash
if pgrep -c youtube-dl > /dev/null; then
  # echo "Last download task still running, exit"
  exit;
fi

if pgrep -c qshell > /dev/null; then
  # echo "Last upload task still running, exit"
  exit;
fi



cd $(dirname $0)

git pull

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    qshell=./commands/qshell-linux-x64
elif [[ "$OSTYPE" == "darwin"* ]]; then
    qshell=./commands/qshell-darwin-x64                # Mac OSX
fi

eval $(cat ../.env | xargs)

$qshell account $ACCESS_KEY $SECRET_KEY

file1=${1:-'../to-do-list/to-do-list.txt'}
file2=${2:-'../done-list/done-list.txt'}
printf "Start processing file list...
[$file1] \tas video file list,
[$file2] \tas the finished file list\n"

./commands/download.sh $file1 $file2

if pgrep -c qshell; then
  exit;
fi

if [ -f tmp/current_local_files.tmp ]
then
while read file; do
  printf "Start uploading $file\n"
  ($qshell rput $BUCKET_NAME "shell_upload/$file" "./$file")
done < tmp/current_local_files.tmp
rm -f tmp/current_local_files.tmp
fi

# $qshell qupload 4 ./config/qshell_config.json
