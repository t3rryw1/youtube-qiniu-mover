## Youtube-download

此项目可用来将youtube以及其他类似视频网站的内容搬移到qiniu的云空间内

#### Server


#### client

可在任意一台mac/linux机器上，配置好client端，然后便可随时添加需要搬移的文件

客户端需要安装工具:

1. rsync 
2. sshpass

客户端需要配置根目录下的.env文件，范例如下：

```
    BUCKET_NAME=cozystay-galaxy-bucket1-hb
    ACCESS_KEY=dzTaOTcLAA-SQY9Ky2Vs9wJqaci5FyDOEgjK_dQq
    SECRET_KEY=Y6O1QoMFYUU62SwPo8QhTxEm-uZ7GicpbivpfogX
    RSNYC_PASSWORD=meifujia138!QAZ
    RSYNC_SERVER_USER=root
    RSYNC_SERVER_ADDRESS=47.88.231.26
    RSYNC_SERVER_PATH=/root/youtube-qiniu-mover

```

运行方式 `./client/add_video.sh url`
