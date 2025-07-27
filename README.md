# 服务端一键安装脚本
```
curl -sS https://raw.githubusercontent.com/bi4nbn/sing-box_auto/main/singbox_server_install.sh | bash
```
# 10秒内自动安装以下三种协议

```
anytls://nt0538@你服务器ip:3538?security=tls&sni=bing.com#AnyTLS(tcp)
hysteria2://nt0538@你服务器ip:1538?sni=bing.com&alpn=h2&insecure=1#Hysteria2(udp)
vless://nt0538@你服务器ip:2538?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.tesla.com&fp=chrome&pbk=I8mdTZIKlw1eCiPei9KUqu4Kpxu1E6an3kXgQ8BSwEQ&sid=0538&type=tcp&headerType=none#Vless(tcp+reality)

```


一键root
```
bash <(curl -sSL https://raw.githubusercontent.com/bi4nbn/sing-box_auto/refs/heads/main/root.sh)
```
