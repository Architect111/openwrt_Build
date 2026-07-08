#!/bin/bash
#===============================================
# 全局下载参数：超时60s，重试5次，根治wget error4/8、下载中断
export WGET_OPTS="--timeout=60 --tries=5"
GH_MIRROR="${USTC_GITHUB_MIRROR}"
USTC_MIRROR="${USTC_IMMORTALWRT}"

#===============================================
# 基础固件自定义（仅编译整机固件生效，IPK编译无副作用）
# Modify default LAN IP 192.168.1.1 → 192.168.1.251
sed -i 's/192.168.1.1/192.168.1.251/g' package/base-files/files/bin/config_generate

# Modify default theme（整机固件启用）
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname（整机固件启用）
#sed -i 's/OpenWrt/kenzo/g' package/base-files/files/bin/config_generate

#2. 工具链/系统底层优化（整机固件压缩、密码配置）
#sed -i 's?zstd$?zstd ucl upx\n$(curdir)/upx/compile := $(curdir)/ucl/compile?g' tools/Makefile
#sed -i 's/$(TARGET_DIR)) install/$(TARGET_DIR)) install --force-overwrite/' package/Makefile
#sed -i 's/root:.*/root:$1$tTPCBw1t$ldzfp37h5lSpO9VXk4uUE\/:18336:0:99999:7:::/g' package/base-files/files/etc/shadow

# ====================== 前置清理feeds，解决重复源报错 ======================
# 直接清空原有feeds.conf.default，杜绝重复追加
> feeds.conf.default

# ====================== 按顺序添加全部仓库（中科大稳定镜像） ======================
# 1. ImmortalWrt官方底层核心包（master分支，适配ipq60xx）
echo "src-git packages ${GH_MIRROR}/immortalwrt/packages.git;master" >> feeds.conf.default
echo "src-git luci ${GH_MIRROR}/immortalwrt/luci.git;master" >> feeds.conf.default
echo "src-git routing ${GH_MIRROR}/immortalwrt/routing.git;master" >> feeds.conf.default
echo "src-git telephony ${GH_MIRROR}/immortalwrt/telephony.git;master" >> feeds.conf.default
echo "src-git video ${GH_MIRROR}/immortalwrt/video.git;master" >> feeds.conf.default

# 2. Fork kenzok8/openwrt-packages（small插件库）
echo "src-git small ${GH_MIRROR}/Architect111/openwrt-packages.git" >> feeds.conf.default

# 3. small-package 额外插件合集
echo "src-git smallpkg ${GH_MIRROR}/Architect111/small-package.git" >> feeds.conf.default

# 4. 个人私有仓库（vnt、quickstart自定义包）
echo "src-git mypkg ${GH_MIRROR}/Architect111/my_personal_packages.git" >> feeds.conf.default

# ====================== 全局替换源码下载镜像（中科大） ======================
sed -i "s|https://downloads.immortalwrt.org|${USTC_MIRROR}|g" feeds.conf.default

# ====================== 刷新安装全部软件源（编译插件核心步骤） ======================
./scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a

# ====================== 可选配置（注释保留，按需启用） ======================
# 批量删除不需要的插件，减少编译体积
# rm -rf feeds/small/luci-app-alist feeds/small/luci-app-passwall feeds/small/luci-app-mosdns

# 整机固件默认内置主题/首页
# echo "CONFIG_PACKAGE_luci-theme-argon=y" >> .config
# echo "CONFIG_PACKAGE_luci-app-quickstart=y" >> .config
