#!/bin/bash

green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

[[ $EUID -ne 0 ]] && su='sudo' || su=''

# 取消 /etc/passwd 和 /etc/shadow 的 chattr 不可变和追加属性（忽略错误）
$su chattr -i /etc/passwd /etc/shadow 2>/dev/null || true
$su chattr -a /etc/passwd /etc/shadow 2>/dev/null || true

prl=$(grep -E "^\s*#?\s*PermitRootLogin" /etc/ssh/sshd_config)
pa=$(grep -E "^\s*#?\s*PasswordAuthentication" /etc/ssh/sshd_config)

if [[ -n $prl && -n $pa ]]; then
    default_pass="Nihao0538"
    read -p "请输入root密码（默认密码: $default_pass，直接回车即用默认密码）: " mima
    if [[ -z "$mima" ]]; then
        mima=$default_pass
    fi

    echo "root:$mima" | $su chpasswd

    $su sed -i 's/^\s*#\?\s*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    $su sed -i 's/^\s*#\?\s*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

    if command -v systemctl >/dev/null 2>&1; then
        $su systemctl restart sshd.service 2>/dev/null || $su systemctl restart ssh.service 2>/dev/null
    else
        $su service sshd restart 2>/dev/null || $su service ssh restart 2>/dev/null
    fi

    green "VPS当前用户名：root"
    green "VPS当前root密码：$mima"
else
    red "当前VPS不支持root账户或无法自定义root密码，或sshd_config配置异常。"
    exit 1
fi
