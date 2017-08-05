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
    BUCKET_NAME=%使用的qiniu bucket%
    ACCESS_KEY=%七牛access key%
    SECRET_KEY=%七牛secrect key%
    RSNYC_PASSWORD=%服务端登录密码%
    RSYNC_SERVER_USER=%服务端用户名%
    RSYNC_SERVER_ADDRESS=%服务端登录地址%
    RSYNC_SERVER_PATH=%服务端项目路径%

```

运行方式 `./client/add_video.sh url`

服务端需要运行 `./server/download.sh` 与 `./server/upload.sh` 两个crontab，并设置对应的.env文件。
