cd $(dirname $0)
echo $(PWD)

# import env file
eval $(cat ../.env | xargs)

if [ -z "$1" ]; then
  echo "Usage: ./add_video_list.sh playlist_id"
  exit;
fi

youtube-dl --flat-playlist $1 --print-json | sed -n "s/^.*\"id\": \"\([^\"]*\).*/\1/gp" >> ../file-list/to-do/to-do-list.txt

# echo "Adding $1 to download list"
# printf "$1\n" >>../file-list/to-do/to-do-list.txt
sshpass -p $RSNYC_PASSWORD rsync -a ../file-list/to-do/ $RSYNC_SERVER_USER@$RSYNC_SERVER_ADDRESS:$RSYNC_SERVER_PATH/file-list/to-do
