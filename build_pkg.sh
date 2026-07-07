#!/bin/bash
# OpenWrt / ImmortalWrt 本地一键编译脚本
# 用法：./build_pkg.sh 包名1 包名2 ...
# 示例：./build_pkg.sh luci-app-vnt luci-app-quickfile-go

# 校验输入参数
if [ $# -eq 0 ]; then
    echo "===== 使用帮助 ====="
    echo "格式：$0 插件包名1 插件包名2"
    echo "示例1：仅编译VNT客户端"
    echo "  $0 luci-app-vnt"
    echo "示例2：批量编译多个插件"
    echo "  $0 luci-app-vnt luci-app-quickfile-go luci-app-frp"
    echo "==================="
    exit 1
fi

# 循环编译传入的所有包名
PACK_LIST=("$@")
for pkg in "${PACK_LIST[@]}"; do
    echo -e "\n====================================="
    echo "正在编译插件：$pkg"
    echo "====================================="
    make package/$pkg/compile -j$(nproc) V=s
    if [ $? -eq 0 ]; then
        echo -e "\n✅ $pkg 编译成功"
    else
        echo -e "\n❌ $pkg 编译失败，请核对包名是否存在"
    fi
done

echo -e "\n===== 全部编译任务执行完成 ====="
echo "IPK输出目录：bin/packages/对应架构/base/"
