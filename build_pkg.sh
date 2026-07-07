#!/bin/bash
# 双模式通用脚本：云端传参编译 / 本地无参自动读取menuconfig=M插件
export WGET_OPTS="--timeout=60 --tries=5"

# 提取.config中M标记插件
get_m_packages() {
    grep '^CONFIG_PACKAGE_.*=m' .config | sed -e 's/^CONFIG_PACKAGE_//' -e 's/=m$//'
}

# 判断传参逻辑
if [ $# -gt 0 ]; then
    # 有参数：云端Action模式，使用传入的插件列表
    PACK_LIST=("$@")
    echo "【云端模式】使用传入插件列表：${PACK_LIST[*]}"
else
    # 无参数：本地整机编译模式，读取menuconfig里=M的插件
    PACK_LIST=($(get_m_packages))
    if [ ${#PACK_LIST[@]} -eq 0 ]; then
        echo "错误：无传入参数，且.config无<M>插件，请二选一："
        echo "1. 本地：执行 make menuconfig 将插件设为<M>保存"
        echo "2. 云端：在workflow输入框填写pkg_list"
        exit 1
    fi
    echo "【本地整机配套模式】读取menuconfig标记<M>的插件：${PACK_LIST[*]}"
fi

echo "====================================="
# 批量编译
for pkg in "${PACK_LIST[@]}"; do
    echo -e "\n【编译】$pkg"
    make package/$pkg/clean V=s
    make package/$pkg/compile V=s
    if [ $? -eq 0 ]; then
        echo "✅ $pkg OK"
    else
        echo "❌ $pkg FAILED"
    fi
done

# 生成索引
make package/index
ARCH=$(grep 'CONFIG_TARGET_ARCH_PACKAGES' .config | cut -d'=' -f2 | tr -d '"')
echo -e "\n全部完成，IPK路径：bin/packages/$ARCH/"
