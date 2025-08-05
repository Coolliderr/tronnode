#!/bin/bash

set -e

### === 基本配置 === ###
WORKDIR="/opt/tron"
TOOLS_DIR="/opt/tools"
SNAPSHOT_URL="http://34.143.247.77/backup20250801/LiteFullNode_output-directory.tgz"
MD5_URL="http://34.143.247.77/backup20250801/LiteFullNode_output-directory.tgz.md5sum"
JAR_URL="https://github.com/tronprotocol/java-tron/releases/download/GreatVoyage-v4.7.7/FullNode.jar"
CONF_URL="https://raw.githubusercontent.com/tronprotocol/tron-deployment/master/main_net_config.conf"

### === 安装基础软件 === ###
echo "📦 安装依赖（openjdk-8、wget、curl、jq）..."
apt update
apt install -y openjdk-8-jdk wget curl jq vim

echo "✅ 当前 Java 版本："
java -version

### === 创建目录 === ###
echo "📁 创建工作目录..."
mkdir -p "$WORKDIR" "$TOOLS_DIR"
cd "$TOOLS_DIR"

### === 下载 Tron 快照和 MD5 校验 === ###
echo "⬇️ 下载 Tron 快照数据..."
wget -c "$SNAPSHOT_URL" -O LiteFullNode_output-directory.tgz
wget -c "$MD5_URL" -O LiteFullNode_output-directory.tgz.md5sum

echo "🔐 校验 MD5..."
MD5_REMOTE=$(cut -d ' ' -f1 < LiteFullNode_output-directory.tgz.md5sum)
MD5_LOCAL=$(md5sum LiteFullNode_output-directory.tgz | cut -d ' ' -f1)

if [[ "$MD5_REMOTE" != "$MD5_LOCAL" ]]; then
  echo "❌ MD5 校验失败，文件可能损坏，退出"
  exit 1
fi

echo "✅ MD5 校验通过"

### === 解压快照数据 === ###
echo "📦 解压快照数据到 $WORKDIR"
tar zxvf LiteFullNode_output-directory.tgz -C "$WORKDIR"

### === 下载 FullNode.jar === ###
echo "⬇️ 下载 FullNode.jar..."
cd "$WORKDIR"
wget -c "$JAR_URL"

### === 下载并修改配置文件 === ###
echo "⚙️ 下载并修改 main_net_config.conf..."
wget -O main_net_config.conf "$CONF_URL"

# 修改配置项
sed -i 's/supportConstant = false/supportConstant = true/' main_net_config.conf
sed -i 's/maxTimeRatio = 5.0/maxTimeRatio = 20.0/' main_net_config.conf
sed -i 's/openHistoryQueryWhenLiteFN = false/openHistoryQueryWhenLiteFN = true/' main_net_config.conf

### === 启动 Tron 节点 === ###
echo "🚀 启动 Tron 节点..."
nohup java -Xms12g -Xmx12g -jar FullNode.jar -c main_net_config.conf > output.log 2>&1 &

echo "✅ 启动完成，日志路径：$WORKDIR/output.log"
echo "使用命令查看同步状态：tail -f $WORKDIR/output.log | grep -i sync"
