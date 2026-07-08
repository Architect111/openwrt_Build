#!/bin/bash
export WGET_OPTS="--timeout=60 --tries=5"
GH_MIRROR="${USTC_GITHUB_MIRROR}"
OPENWRT_MIRROR="${USTC_OPENWRT}"

# 清空原有feeds
> feeds.conf.default
# OpenWrt官方源
echo "src-git packages ${GH_MIRROR}/openwrt/packages.git;openwrt-24.10" >> feeds.conf.default
echo "src-git luci ${GH_MIRROR}/openwrt/luci.git;openwrt-24.10" >> feeds.conf.default
echo "src-git routing ${GH_MIRROR}/openwrt/routing.git;openwrt-24.10" >> feeds.conf.default
# 你的第三方插件库
echo "src-git small ${GH_MIRROR}/Architect111/openwrt-packages.git" >> feeds.conf.default
echo "src-git smallpkg ${GH_MIRROR}/Architect111/small-package.git" >> feeds.conf.default
echo "src-git mypkg ${GH_MIRROR}/Architect111/my_personal_packages.git" >> feeds.conf.default

# 替换下载镜像
sed -i "s|https://downloads.openwrt.org|${OPENWRT_MIRROR}|g" feeds.conf.default

# 更新安装feeds
./scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a

# ========== 新增：自动修复双层嵌套luci-app-quickfile-go ==========
# 进入拉取完成的mypkg仓库目录
cd feeds/mypkg
# 将内层完整插件复制到一级目录
cp -r luci-app-quickfile-go/luci-app-quickfile-go ./
# 删除多余外层嵌套文件夹
rm -rf luci-app-quickfile-go
# 返回源码根目录
cd ../../
