## 📌 安装波场轻节点

1✅、转换格式
```bash
sudo apt install dos2unix -y
dos2unix install_tron_lite_node.sh
```

2✅、运行脚本~启动节点
```bash
chmod +x install_tron_lite_node.sh
sudo ./install_tron_lite_node.sh
```

3✅、等待一两分钟后，查看节点状况
```bash
# 查看是否还有 FullNode.jar 正在运行
ps aux | grep FullNode | grep -v grep

# 查看日志末尾（不要加过滤）
sudo tail -n 50 /opt/tron/output.log
```

4✅、查看区块高度
```bash
curl -s http://127.0.0.1:8090/wallet/getnowblock | jq '.block_header.raw_data.number'
```
