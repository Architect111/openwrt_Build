#!/bin/bash
export WGET_OPTS="--timeout=60 --tries=5"

# 提取.config中标记=M的插件
get_m_packages() {
    grep '^CONFIG_PACKAGE_.*=m' .config | sed -e 's/^CONFIG_PACKAGE_//' -e 's/=m$//'
}

# 双模式判断
if [ $# -gt 0 ]; then
    PACK_LIST=("$@")
    echo "【云端编译模式】待编译插件：${PACK_LIST[*]}"
else
    PACK_LIST=($(get_m_packages))
    if [ ${#PACK_LIST[@]} -eq 0 ]; then
        echo "错误：无传入参数，且.config无<M>标记插件，请执行 make menuconfig 设置插件为<M>"
        exit 1
    fi
    echo "【本地整机配套模式】读取menuconfig<M>插件：${PACK_LIST[*]}"
fi

echo "====================================="
# 循环编译
for pkg in "${PACK_LIST[@]}"; do
    echo -e "\n【开始编译】$pkg"
    make package/$pkg/clean V=s
    make package/$pkg/compile V=s
    if [ $? -eq 0 ]; then
        echo "✅ $pkg 编译成功"
    else
        echo "❌ $pkg 编译失败，请检查包名/feeds源"
    fi
done

# 生成离线安装必需索引
echo -e "\n生成Packages.gz软件包索引"
make package/index

# 自动读取架构输出路径
ARCH=$(grep 'CONFIG_TARGET_ARCH_PACKAGES' .config | cut -d'=' -f2 | tr -d '"')
echo -e "\n===== 全部编译完成 ====="
echo "IPK存放根目录：bin/packages/$ARCH/"
