#!/bin/bash
# 红警2网页版 - 本地服务器启动脚本

echo "=========================================="
echo "  红警2网页版 - 本地服务器"
echo "=========================================="
echo ""

cd "$(dirname "$0")"

# 自动更新 config.ini 中的 IP 地址
if [ -f "update-config-ip.sh" ]; then
    ./update-config-ip.sh
fi

echo ""
echo "正在启动服务器..."
echo ""

# 检查8000端口是否被占用
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "⚠️  端口 8000 已被占用!"
    echo "请先关闭占用端口的程序,或修改端口号"
    echo ""
    echo "查看占用进程: lsof -i :8000"
    echo "结束进程: kill -9 \$(lsof -t -i :8000)"
    exit 1
fi

echo "✅ 服务器已启动在: http://localhost:8000"
echo "✅ 局域网访问: http://$(hostname -I | awk '{print $1}'):8000"
echo ""
echo "📁 当前目录: $(pwd)"
echo "📂 资源目录: $(pwd)/res"
echo ""
echo "按 Ctrl+C 停止服务器"
echo "=========================================="
echo ""

# 绑定到所有网络接口 (0.0.0.0),允许局域网访问
python3 -m http.server 8000 --bind 0.0.0.0
