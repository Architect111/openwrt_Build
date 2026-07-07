#!/bin/bash
#===============================================
# 基础固件自定义修改（IP、主机名、密码等，全部保留原有逻辑）
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
# 删除源码自带packages源，杜绝 Duplicate feed name 'packages'
sed -i '/^src-git packages/d' feeds.conf.default
# 删除旧small残留源
sed -i '/src-git small/d' feeds.conf.default
sed -i '/src-git openwrt-packages/d' feeds.conf.default
sed -i '/src-git mypkg/d' feeds.conf.default

# ====================== 按顺序添加全部3个你的仓库 + ImmortalWrt官方包 ======================
# 1. ImmortalWrt官方底层核心包（master分支，适配25.x APK、ipq60xx）
echo "src-git packages https://github.com/immortalwrt/packages.git;master" >> feeds.conf.default

# 2. 你Fork的 kenzok8/openwrt-packages（别名small，大量luci插件）
echo "src-git small https://github.com/Architect111/openwrt-packages.git" >> feeds.conf.default

# 3. small-package 额外插件合集
echo "src-git smallpkg https://github.com/Architect111/small-package.git" >> feeds.conf.default

# 4. 你的个人私有仓库（vnt、自定义quickstart、私有工具）
echo "src-git mypkg https://github.com/Architect111/my_personal_packages.git" >> feeds.conf.default

# ====================== 全局替换国内中科大镜像，根治wget error 8下载中断 ======================
sed -i 's|https://downloads.immortalwrt.org|https://mirrors.ustc.edu.cn/immortalwrt|g' feeds.conf.default

# ====================== 刷新安装全部软件源 ======================
./scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a

# ====================== 可选：批量删除不需要的插件，减少编译体积 ======================
# rm -rf feeds/small/luci-app-alist feeds/small/luci-app-passwall feeds/small/luci-app-mosdns

# ====================== 可选：默认勾选Argon主题+Quickstart首页 ======================
# echo "CONFIG_PACKAGE_luci-theme-argon=y" >> .config
# echo "CONFIG_PACKAGE_luci-app-quickstart=y" >> .config
