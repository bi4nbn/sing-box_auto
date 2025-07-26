#!/bin/bash

set -e

green(){ echo -e "\033[32m\033[01m$1\033[0m"; }
red(){ echo -e "\033[31m\033[01m$1\033[0m"; }

[[ $EUID -ne 0 ]] && SUDO='sudo' || SUDO=''

# 设置 root 密码
default_pass="Nihao0538"
read -p "请输入 root 密码（默认: $default_pass）: " pass
[[ -z "$pass" ]] && pass="$default_pass"

green "▶ 设置 root 密码..."
$SUDO passwd -u root 2>/dev/null || true
echo "root:$pass" | $SUDO chpasswd
green "✔ root 密码设置成功"

# 修改 SSH 配置
sshd_conf="/etc/ssh/sshd_config"

green "▶ 修改 SSH 配置，启用 root 密码登录..."
$SUDO sed -i '/^PermitRootLogin/d' "$sshd_conf"
$SUDO sed -i '/^PasswordAuthentication/d' "$sshd_conf"
$SUDO sed -i '/^UsePAM/d' "$sshd_conf"

echo "PermitRootLogin yes" | $SUDO tee -a "$sshd_conf" >/dev/null
echo "PasswordAuthentication yes" | $SUDO tee -a "$sshd_conf" >/dev/null
echo "UsePAM yes" | $SUDO tee -a "$sshd_conf" >/dev/null
green "✔ SSH 配置修改完成"

# 兼容 cloud-init：修改 cloud.cfg
cfg="/etc/cloud/cloud.cfg"
if [[ -f $cfg ]]; then
    green "▶ 配置 cloud-init，允许 root 密码登录..."
    $SUDO sed -i '/^disable_root/d' $cfg
    $SUDO sed -i '/^ssh_pwauth/d' $cfg
    $SUDO sed -i '/^lock_passwd/d' $cfg
    echo "disable_root: 0" | $SUDO tee -a $cfg >/dev/null
    echo "ssh_pwauth: 1" | $SUDO tee -a $cfg >/dev/null
    green "✔ cloud.cfg 修改完成"
fi

# 禁用 cloud-init 对 SSH 配置的干预（防止覆盖）
green "▶ 禁用 cloud-init 的 SSH 模块（防止干扰）..."
$SUDO touch /etc/cloud/cloud-init.disabled || true
green "✔ 已禁用 cloud-init（永久生效）"

# 重启 SSH 服务
green "▶ 重启 SSH 服务..."
if command -v systemctl >/dev/null; then
    $SUDO systemctl restart ssh || $SUDO systemctl restart sshd
else
    $SUDO service ssh restart || $SUDO service sshd restart
fi
green "✔ SSH 服务已重启"

# 最终确认
green "✅ 配置已完成！你现在可以使用如下账号登录："
echo
green "▶ 用户名：root"
green "▶ 密码：$pass"
echo
green "▶ 请通过 ssh root@你的IP 测试连接。重启后仍然生效。"
