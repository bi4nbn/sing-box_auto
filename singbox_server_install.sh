#!/bin/bash

# 创建所需目录并生成SSL证书
mkdir -p /etc/hysteria
openssl ecparam -genkey -name prime256v1 -out /etc/hysteria/private.key
openssl req -new -x509 -days 36500 -key /etc/hysteria/private.key -out /etc/hysteria/cert.pem -subj "/CN=bing.com"

# 运行安装脚本
bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh) install 1.9.0-rc.3

# 创建/修改配置文件
wget -O /usr/local/etc/sing-box/config.json https://github.com/bi4nbn/sing-box_auto/raw/main/server.json

# 重启sing-box
sing-box restart
