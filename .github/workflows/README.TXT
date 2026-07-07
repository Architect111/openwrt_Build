# 云端 GitHub Actions 编译脚本
# 一、脚本使用方法
将上述代码保存为 .github/workflows/cloud_compile.yml，提交推送至你的 openwrt_Build 仓库；
进入仓库顶部 Actions 标签，找到「云端按需编译 IPK」；
点击 Run workflow，在弹窗输入：
packages：填写你要编译的包名，空格分隔，示例 luci-app-vnt luci-app-quickfile-go
target_arch：填写路由器架构（x86_64 /aarch64_cortex-a53 等）
点击 Run workflow 自动云端编译，完成后在仓库 Releases 页面下载打包好的 IPK。
