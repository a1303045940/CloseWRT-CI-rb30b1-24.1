#!/bin/bash

#修改默认主题
#sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
#sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_MARK-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")
#sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ by vx:Mr___zjz-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")




# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow


#根据源码来修改


CFG_FILE="/package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE



#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
#echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo -e "$WRT_PACKAGE" >> ./.config
fi

sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default

#根据源码来修改
#if [[ $WRT_REPO == *"lede"* ]]; then
LEDE_FILE=$(find ./package/lean/autocore/ -type f -name "index.htm")
#修改默认时间格式
sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M 星期%w")/g' $LEDE_FILE

#修改luc显示版本改成系统版本
sed -i "735s/<%=pcdata(ver\.luciname)%> (<%=pcdata(ver\.luciversion)%>)/openwrt-24.10.3/" package/lean/autocore/files/arm/index.htm

# 注释原行（精确匹配原URL和版本）
#sed -i '/src-git luci https:\/\/github.com\/coolsnowwolf\/luci\.git;openwrt-23.05/s/^/#/' "feeds.conf.default"
# 添加新行到文件末尾
#24.1 uci
#echo "src-git luci https://github.com/coolsnowwolf/luci.git;openwrt-24.10" >> "feeds.conf.default"

#echo "src-git luci https://github.com/coolsnowwolf/luci.git" >> "feeds.conf.default"


# 获取编译日期
date_version=$(date +"%Y年%m月%d日")
# 获取原始版本
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
# 获取 VERSION 信息
#VERSION_NAME=$(grep "DISTRIB_ID=" package/base-files/files/usr/lib/os-release | cut -d'=' -f2)
#VERSION=$(grep "DISTRIB_RELEASE=" package/base-files/files/usr/lib/os-release | cut -d'=' -f2)

VERSION_NAME=$(grep "ID=" package/base-files/files/usr/lib/os-release | cut -d'=' -f2)
VERSION=$(grep "PRETTY_NAME=" package/base-files/files/usr/lib/os-release | cut -d'=' -f2)
# 生成新版本字符串
#new_version="${VERSION_NAME}  ${VERSION}   by 微信:Mr___zjz 编译日期：${date_version}"
new_version="${VERSION}   by 微信:Mr___zjz 编译日期：${date_version}"
# 使用 sed 替换（使用 | 作为分隔符避免斜杠冲突）
new_version="openwrt 24.10.3   by 微信:Mr___zjz 编译日期：${date_version}"
sed -i "s|${orig_version}|${new_version}|g" package/lean/default-settings/files/zzz-default-settings

#修改默认WIFI名
#sed -i "s/\.ssid=.*/\.ssid=Openwrt/g" $(find ./package/kernel/mac80211/ ./package/network/config/ -type f -name "mac80211.*")

#添加第三方软件源
sed -i "s/option check_signature/# option check_signature/g" package/system/opkg/Makefile
echo src/gz openwrt_kiddin9 https://dl.openwrt.ai/latest/packages/aarch64_cortex-a53/kiddin9 >> ./package/system/opkg/files/customfeeds.conf

# 最大连接数修改为65535
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf
	
#开机启动文件rc.local替换

#cp "$GITHUB_WORKSPACE/Scripts/npc/npc" package/base-files/files/etc/init.d/npc
#chmod +x package/base-files/files/etc/init.d/npc
cp "$GITHUB_WORKSPACE/Scripts/npc/npc.conf" package/base-files/files/etc/npc.conf
chmod +x package/base-files/files/etc/npc.conf

#调整mtk系列配置
sed -i '/TARGET.*mediatek/d' ./.config
sed -i '/TARGET_MULTI_PROFILE/d' ./.config
sed -i '/TARGET_PER_DEVICE_ROOTFS/d' ./.config
sed -i '/luci-app-eqos/d' ./.config
sed -i '/luci-app-mtk/d' ./.config
sed -i '/luci-app-upnp/d' ./.config
sed -i '/luci-app-wol/d' ./.config
sed -i '/wifi-profile/d' ./.config
