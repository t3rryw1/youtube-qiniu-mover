#!/usr/bin/env bash
cd $(dirname $0)

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  if pgrep -c qshell > /dev/null; then
    exit;
  fi
  qshell=./commands/qshell-linux-x64
elif [[ "$OSTYPE" == "darwin"* ]]; then
  if pgrep qshell  > /dev/null; then
    exit;
  fi
  qshell=./commands/qshell-darwin-x64                # Mac OSX
fi

echo "Detecting qshell path..."

test -z $qshell && echo "Exiting: qshell executable does not exist!" && exit

eval $(cat ../.env | xargs)

ACCESS_KEY=${ACCESS_KEY:?"Need to set ACCESS_KEY non-empty in .env file"}
SECRET_KEY=${SECRET_KEY:?"Need to set SECRET_KEY non-empty in .env file"}
$qshell account $ACCESS_KEY $SECRET_KEY



eval $(cat ../.env | xargs)

git pull > /dev/null

top_line=$(find videos | egrep -e "(.*\.webm)$|(.*\.mp4)$" |  head -n1 | sed -e 's/^videos\///g')
top_line=${top_line:?"No new files need uploading, exit"}
if $qshell stat $BUCKET_NAME "shell_upload/$top_line" > /dev/null ; then
  echo "File exists in current bucket, remove and skipping"
  && rm -f "./videos/$top_line"
else
  printf "Start uploading videos/$top_line\n"
  # exit
  $qshell rput $BUCKET_NAME "shell_upload/$top_line" "./videos/$top_line" 1 \
  && echo "Finish uploading file, clean file" \
  && rm -f "./videos/$top_line"
  echo "Complete uploading task"
fi
