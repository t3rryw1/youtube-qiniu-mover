cd $(dirname $0)
echo $(PWD)

# import env file
eval $(cat ../.env | xargs)

if [ -z "$1" ]; then
  echo "Usage: ./add_video.sh url"
  exit;
fi

echo "Adding $1 to download list"
printf "$1\n" >>../file-list/to-do/to-do-list.txt
sshpass -p $RSNYC_PASSWORD rsync -a ../file-list/to-do/ $RSYNC_SERVER_USER@$RSYNC_SERVER_ADDRESS:$RSYNC_SERVER_PATH/file-list/to-do
