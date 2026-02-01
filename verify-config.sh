#!/bin/bash
# 快速验证配置是否正确

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         配置验证 - 手机资源自动加载                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# 1. 检查文件存在
echo "📦 检查资源文件..."
if [ -f "res/full-pack.7z" ]; then
    SIZE=$(ls -lh res/full-pack.7z | awk '{print $5}')
    echo "   ✅ full-pack.7z 存在"
    echo "   📊 文件大小: $SIZE"
else
    echo "   ❌ full-pack.7z 不存在!"
    echo "   请确保文件在: res/full-pack.7z"
    exit 1
fi
echo ""

# 2. 检查配置
echo "⚙️  检查 config.ini 配置..."
PACK_URL=$(grep "defaultFullyPackUrl" config.ini | grep -v "^#" | cut -d'=' -f2)
if [ "$PACK_URL" == "/res/full-pack.7z" ]; then
    echo "   ✅ defaultFullyPackUrl=/res/full-pack.7z"
    echo "   ✅ 使用相对路径 (支持所有访问方式)"
elif [[ "$PACK_URL" == *"localhost"* ]]; then
    echo "   ⚠️  配置使用 localhost: $PACK_URL"
    echo "   ❌ 这将导致手机无法自动加载!"
    echo "   建议改为: /res/full-pack.7z"
else
    echo "   配置: $PACK_URL"
fi
echo ""

# 3. 检查服务器
echo "🖥️  检查服务器状态..."
if lsof -i :8000 >/dev/null 2>&1; then
    echo "   ✅ 服务器正在运行"
    
    # 获取IP
    IP=$(hostname -I | awk '{print $1}')
    echo "   📡 本机IP: $IP"
    echo ""
    
    # 测试访问
    echo "🧪 测试文件访问..."
    
    # 测试本地访问
    if curl -s -I http://localhost:8000/res/full-pack.7z | grep -q "200 OK"; then
        echo "   ✅ http://localhost:8000/res/full-pack.7z - 可访问"
    else
        echo "   ❌ http://localhost:8000/res/full-pack.7z - 无法访问"
    fi
    
    # 测试IP访问
    if curl -s -I http://$IP:8000/res/full-pack.7z --max-time 3 | grep -q "200 OK"; then
        echo "   ✅ http://$IP:8000/res/full-pack.7z - 可访问"
    else
        echo "   ❌ http://$IP:8000/res/full-pack.7z - 无法访问"
    fi
else
    echo "   ❌ 服务器未运行!"
    echo "   请启动服务器: ./start-server.sh"
    exit 1
fi
echo ""

# 4. 显示访问地址
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🎮 访问地址                                                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "本机:  http://127.0.0.1:8000"
echo "手机:  http://$IP:8000"
echo ""

# 5. 提示
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  ⚠️  重要提示                                                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "如果之前访问过,必须清除浏览器缓存:"
echo ""
echo "【PC浏览器】"
echo "  - 按 F12 打开开发者工具"
echo "  - 右键点击刷新按钮"
echo "  - 选择 '清空缓存并硬性重新加载'"
echo ""
echo "【手机浏览器】"
echo "  - 设置 → 隐私 → 清除浏览数据"
echo "  - 选择 '缓存的图片和文件'"
echo "  - 清除后重新访问"
echo ""
echo "首次加载需要 5-15 分钟 (下载+解压 134MB)"
echo "请耐心等待,不要刷新页面!"
echo ""
