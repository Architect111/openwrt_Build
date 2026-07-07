#!/bin/bash
#===============================================
# 全局下载参数：超时60s，重试5次，根治unexpected end of file、wget error4/8
export WGET_OPTS="--timeout=60 --tries=5"
GH_PROXY="https://mirror.ghproxy.com/"
USTC_MIRROR="https://mirrors.ustc.edu.cn/immortalwrt"

#===============================================
# 基础固件自定义修改（纯编译IPK时不影响插件编译，保留）
# Modify default LAN IP 192.168.1.1 → 192.168.1.251
sed -i 's/192.168.1.1/192.168.1.251/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/kenzo/g' package/base-files/files/bin/config_generate

#2. 工具链/系统自定义参数
#sed -i 's?zstd$?zstd ucl upx\n$(curdir)/upx/compile := $(curdir)/ucl/compile?g' tools/Makefile
#sed -i 's/$(TARGET_DIR)) install/$(TARGET_DIR)) install --force-overwrite/' package/Makefile
#sed -i 's/root:.*/root:$1$tTPCBw1t$ldzfp37h5lSpO9VXk4uUE\/:18336:0:99999:7:::/g' package/base-files/files/etc/shadow

# ====================== 前置清理feeds，解决重复源报错 ======================
# 直接清空原有feeds.conf.default，杜绝重复追加
> feeds.conf.default

# ====================== 按顺序添加全部仓库，全部ghproxy代理 ======================
# 1. ImmortalWrt官方底层核心包（master分支，适配25.x APK、ipq60xx）
echo "src-git packages ${GH_PROXY}https://github.com/immortalwrt/packages.git;master" >> feeds.conf.default
echo "src-git luci ${GH_PROXY}https://github.com/immortalwrt/luci.git;master" >> feeds.conf.default
echo "src-git routing ${GH_PROXY}https://github.com/immortalwrt/routing.git;master" >> feeds.conf.default
echo "src-git telephony ${GH_PROXY}https://github.com/immortalwrt/telephony.git;master" >> feeds.conf.default
echo "src-git video ${GH_PROXY}https://github.com/immortalwrt/video.git;master" >> feeds.conf.default

# 2. Fork kenzok8/openwrt-packages（small插件库）
echo "src-git small ${GH_PROXY}https://github.com/Architect111/openwrt-packages.git" >> feeds.conf.default

# 3. small-package 额外插件合集
echo "src-git smallpkg ${GH_PROXY}https://github.com/Architect111/small-package.git" >> feeds.conf.default

# 4. 个人私有仓库（vnt、quickstart自定义包）
echo "src-git mypkg ${GH_PROXY}https://github.com/Architect111/my_personal_packages.git" >> feeds.conf.default

# ====================== 全局替换源码下载镜像（中科大） ======================
sed -i "s|https://downloads.immortalwrt.org|${USTC_MIRROR}|g" feeds.conf.default
sed -i "s|https://github.com|${GH_PROXY}https://github.com|g" feeds.conf.default

# ====================== 刷新安装全部软件源 ======================
./scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a

# ====================== 可选：批量删除不需要的插件，减少编译体积 ======================
# rm -rf feeds/small/luci-app-alist feeds/small/luci-app-passwall feeds/small/luci-app-mosdns

# ====================== 可选：默认勾选Argon主题+Quickstart首页 ======================
# echo "CONFIG_PACKAGE_luci-theme-argon=y" >> .config
# echo "CONFIG_PACKAGE_luci-app-quickstart=y" >> .config
