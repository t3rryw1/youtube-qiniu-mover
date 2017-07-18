eval $(cat ../.env | xargs)

if [ -z "$1" ]; then
  echo "Usage: ./add_video.sh url"
  exit;
fi
echo "Adding $1 to download list"
printf "$1\n" >>../to-do-list/to-do-list.txt
sshpass -p $RSNYC_PASSWORD rsync -a ../to-do-list/ $RSYNC_SERVER_USER@$RSYNC_SERVER_ADDRESS:$RSYNC_SERVER_PATH/to-do-list
