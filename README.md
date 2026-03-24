# 服务端一键安装脚本
```
bash <(curl -sSL https://raw.githubusercontent.com/bi4nbn/sing-box_auto/main/singbox_server_install.sh)
```
# 10秒内自动安装以下四种协议

```
anytls://nt0538@你服务器ip:3538?security=tls&sni=bing.com#AnyTLS(tcp)
hysteria2://nt0538@你服务器ip:1538?sni=bing.com&alpn=h2&insecure=1#Hysteria2(udp)
vless://nt0538@你服务器ip:2538?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.tesla.com&fp=chrome&pbk=I8mdTZIKlw1eCiPei9KUqu4Kpxu1E6an3kXgQ8BSwEQ&sid=0538&type=tcp&headerType=none#Vless(tcp+reality)
tuic://d7b1c6b2-6f3a-4a9e-9b2e-8c6e9f5e1a2b@你服务器ip:4538?congestion_control=bbr&udp_relay_mode=native&alpn=h3#TUIC
```


# 一键开启服务器root权限
```
bash <(curl -sSL https://raw.githubusercontent.com/bi4nbn/sing-box_auto/refs/heads/main/root.sh)
```
