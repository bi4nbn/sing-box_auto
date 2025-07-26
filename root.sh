#!/bin/bash

set -e

green(){ echo -e "\033[32m\033[01m$1\033[0m"; }
red(){ echo -e "\033[31m\033[01m$1\033[0m"; }

[[ $EUID -ne 0 ]] && SUDO="sudo" || SUDO=""

default_pass="Nihao0538"
read -p "请输入 root 密码（默认: $default_pass）: " pass
[[ -z "$pass" ]] && pass="$default_pass"

# 解锁 root
$SUDO passwd -u root 2>/dev/null || true
echo "root:$pass" | $SUDO chpasswd
green "✔ 设置 root 密码成功：$pass"

# 修改 sshd_config
conf="/etc/ssh/sshd_config"

# 统一写入配置项（避免被重复项覆盖）
$SUDO sed -i '/^PermitRootLogin/d' "$conf"
$SUDO sed -i '/^PasswordAuthentication/d' "$conf"
$SUDO sed -i '/^UsePAM/d' "$conf"

echo "PermitRootLogin yes" | $SUDO tee -a "$conf"
echo "PasswordAuthentication yes" | $SUDO tee -a "$conf"
echo "UsePAM yes" | $SUDO tee -a "$conf"

# 确保配置有效
green "✔ SSH 配置已修改为允许 root 密码登录"

# 重启 SSH 服务（兼容 systemctl/service）
if command -v systemctl >/dev/null; then
    $SUDO systemctl restart sshd 2>/dev/null || $SUDO systemctl restart ssh
else
    $SUDO service sshd restart 2>/dev/null || $SUDO service ssh restart
fi
green "✔ SSH 服务已重启"

# 再次确认 root 没锁
$SUDO passwd -S root

green "✅ 现在请用 ssh root@你的IP 登录测试。"
