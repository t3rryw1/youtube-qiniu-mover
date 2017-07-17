#!/usr/bin/env bash

git pull

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    qshell=./commands/qshell-linux-x64
elif [[ "$OSTYPE" == "darwin"* ]]; then
    qshell=./commands/qshell-darwin-x64                # Mac OSX
fi

eval $(cat ./config/.env | xargs)

$qshell account $ACCESS_KEY $SECRET_KEY

file1=${1:-'to-do-list/to-do-list.txt'}
file2=${2:-'done-list/done-list.txt'}
printf "Start processing file list...
[$file1] \tas video file list,
[$file2] \tas the finished file list\n"

./commands/download.sh $file1 $file2

$qshell qupload 4 ./config/qshell_config.json
