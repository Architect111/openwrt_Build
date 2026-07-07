#!/bin/bash
#===============================================
# Modify default IP
sed -i 's/192.168.1.1/192.168.1.251/g' openwrt/package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/kenzo/g' openwrt/package/base-files/files/bin/config_generate

#2. Custom settings
#sed -i 's?zstd$?zstd ucl upx\n$(curdir)/upx/compile := $(curdir)/ucl/compile?g' tools/Makefile
#sed -i 's/$(TARGET_DIR)) install/$(TARGET_DIR)) install --force-overwrite/' package/Makefile
#sed -i 's/root:.*/root:$1$tTPCBw1t$ldzfp37h5lSpO9VXk4uUE\/:18336:0:99999:7:::/g' package/base-files/files/etc/shadow

# ====================== 新增：替换插件源为你私有仓库 ======================
# 1. 删除原作者自带的small官方源，避免拉第三方仓库
sed -i '/src-git small/d' feeds.conf.default

# 2. 添加你自己Fork的small插件合集仓库
echo "src-git small https://github.com/Architect111/small-package.git" >> feeds.conf.default

# 3. 添加你的个人私有插件仓库（存放vnt、quickfile-go）
echo "src-git mypkg https://github.com/Architect111/my_personal_packages.git" >> feeds.conf.default

# 4. 可选：添加OpenWrt官方基础包仓库（按需保留）
echo "src-git packages https://github.com/openwrt/packages.git" >> feeds.conf.default

# 5. 更新feeds索引，让编译系统识别你的插件
./scripts/feeds update -a
./scripts/feeds install -a

# ====================== 可选：批量清理不用的插件（减少编译扫描范围） ======================
# 删除small合集里你不用的插件，注释掉不需要的rm行即可
# rm -rf feeds/small/luci-app-alist feeds/small/luci-app-passwall feeds/small/luci-app-mosdns
