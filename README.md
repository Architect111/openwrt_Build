# 本机本地编译脚本 build_pkg.sh
chmod +x build_pkg.sh\
./scripts/feeds update -a
./scripts/feeds install -a
# 单独编译VNT
./build_pkg.sh luci-app-vnt
# 批量编译多个自用插件
./build_pkg.sh luci-app-vnt luci-app-quickfile-go
# 后续新增多层插件扩展写法customize
cp -r luci-app-test/luci-app-test ./
rm -rf luci-app-test
