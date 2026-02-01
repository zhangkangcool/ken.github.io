#!/bin/bash
# 局域网访问测试脚本

echo "╔════════════════════════════════════════════════════════════╗"
echo "║          红警2网页版 - 局域网访问测试                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# 获取本机IP地址
echo "📡 正在获取网络信息..."
echo ""

LOCAL_IPS=$(hostname -I 2>/dev/null || ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d'/' -f1)

echo "🖥️  本机IP地址:"
for ip in $LOCAL_IPS; do
    echo "   - $ip"
done
echo ""

# 检查8000端口
echo "🔍 检查服务器状态..."
if lsof -i :8000 >/dev/null 2>&1; then
    echo "   ✅ 服务器正在运行在端口 8000"
    
    # 检查绑定地址
    BIND_ADDR=$(ss -tlnp 2>/dev/null | grep :8000 | awk '{print $4}' | head -1)
    if [ -z "$BIND_ADDR" ]; then
        BIND_ADDR=$(netstat -tlnp 2>/dev/null | grep :8000 | awk '{print $4}' | head -1)
    fi
    
    echo "   监听地址: $BIND_ADDR"
    
    if [[ "$BIND_ADDR" == "0.0.0.0:8000" ]] || [[ "$BIND_ADDR" == *":8000" ]]; then
        echo "   ✅ 已绑定到所有网络接口,支持局域网访问"
    elif [[ "$BIND_ADDR" == "127.0.0.1:8000" ]]; then
        echo "   ⚠️  只绑定到本地接口,局域网无法访问!"
        echo "   请使用: python3 -m http.server 8000 --bind 0.0.0.0"
    fi
else
    echo "   ❌ 服务器未运行!"
    echo "   请先启动服务器: ./start-server.sh"
    exit 1
fi
echo ""

# 测试本地访问
echo "🧪 测试本地访问..."
if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8000 | grep -q "200"; then
    echo "   ✅ http://127.0.0.1:8000 - 正常"
else
    echo "   ❌ http://127.0.0.1:8000 - 失败"
fi
echo ""

# 测试IP访问
echo "🧪 测试IP地址访问..."
for ip in $LOCAL_IPS; do
    if curl -s -o /dev/null -w "%{http_code}" http://$ip:8000 --max-time 3 | grep -q "200"; then
        echo "   ✅ http://$ip:8000 - 正常"
    else
        echo "   ❌ http://$ip:8000 - 失败"
    fi
done
echo ""

# 检查防火墙
echo "🔥 检查防火墙状态..."
if command -v ufw >/dev/null 2>&1; then
    UFW_STATUS=$(sudo ufw status 2>/dev/null | grep -i "status:" | awk '{print $2}')
    if [ "$UFW_STATUS" == "active" ]; then
        echo "   ⚠️  UFW防火墙已启用"
        if sudo ufw status | grep -q "8000"; then
            echo "   ✅ 端口8000已允许通过"
        else
            echo "   ❌ 端口8000未开放!"
            echo "   执行: sudo ufw allow 8000/tcp"
        fi
    else
        echo "   ℹ️  UFW防火墙未启用"
    fi
else
    echo "   ℹ️  未安装UFW防火墙"
fi
echo ""

# 显示访问URL
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  🌐 访问地址                                               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "本机访问:"
echo "   http://localhost:8000"
echo "   http://127.0.0.1:8000"
echo ""
echo "局域网访问 (其他设备):"
for ip in $LOCAL_IPS; do
    echo "   http://$ip:8000"
done
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  📱 移动设备访问步骤                                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "1. 确保手机/平板连接到相同WiFi网络"
echo "2. 打开浏览器,输入以上局域网地址"
echo "3. 如果无法访问,检查:"
echo "   - 防火墙设置"
echo "   - 路由器是否启用AP隔离"
echo "   - 服务器是否使用 --bind 0.0.0.0 启动"
echo ""
echo "提示: 使用 './start-server.sh' 已包含正确配置"
echo ""
