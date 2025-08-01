#!/bin/bash

set -e

# 彩色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# 系统更新
echo -e "${GREEN}▶ 步骤 0：更新系统...${NC}"

# 检测包管理工具并执行更新
if command -v apt &>/dev/null; then
    echo -e "${GREEN}使用 apt 更新系统...${NC}"
    apt update -y 
elif command -v yum &>/dev/null; then
    echo -e "${GREEN}使用 yum 更新系统...${NC}"
    yum update -y
elif command -v dnf &>/dev/null; then
    echo -e "${GREEN}使用 dnf 更新系统...${NC}"
    dnf update -y
elif command -v pacman &>/dev/null; then
    echo -e "${GREEN}使用 pacman 更新系统...${NC}"
    pacman -Syu --noconfirm
else
    echo -e "${RED}无法识别的包管理工具，跳过更新步骤。${NC}"
fi

# 创建证书目录
CERT_DIR="/etc/hysteria"
CERT_KEY="$CERT_DIR/private.key"
CERT_PEM="$CERT_DIR/cert.pem"
DOMAIN="bing.com"
SINGBOX_VERSION="1.12.0-rc.4"

echo -e "${GREEN}▶ 步骤 1：创建自签证书（有效期100年）...${NC}"
mkdir -p "$CERT_DIR"

if [[ -f $CERT_KEY && -f $CERT_PEM ]]; then
    echo -e "${YELLOW}证书已存在，跳过生成。${NC}"
else
    openssl ecparam -genkey -name prime256v1 -out "$CERT_KEY"
    openssl req -new -x509 -days 36500 -key "$CERT_KEY" -out "$CERT_PEM" -subj "/CN=${DOMAIN}"
    echo -e "${GREEN}✔ 证书已生成：${CERT_PEM}${NC}"
fi

echo -e "${GREEN}▶ 步骤 2：安装 Sing-box v${SINGBOX_VERSION}...${NC}"
sleep 2
bash <(curl -fsSL "https://raw.githubusercontent.com/bi4nbn/sing-box_auto/main/install.sh") install "$SINGBOX_VERSION"

echo -e "${GREEN}▶ 步骤 3：重启 Sing-box 服务...${NC}"
if command -v sing-box &>/dev/null; then
    sing-box restart || echo -e "${RED}❌ sing-box restart 命令执行失败，请检查。${NC}"
else
    systemctl restart sing-box || echo -e "${RED}❌ systemctl restart sing-box 执行失败，请确认服务是否存在。${NC}"
fi

echo -e "${GREEN}▶ 步骤 4：打印实时日志（按 Ctrl+C 退出）...${NC}"
sing-box log
