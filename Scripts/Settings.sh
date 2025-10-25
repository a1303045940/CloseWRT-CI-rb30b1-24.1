#!/bin/bash

#修改默认主题
#sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
#sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_MARK-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ by vx:Mr___zjz-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")




# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow


#根据源码来修改
if [[ $WRT_URL != *"lede"* ]]; then
	LEDE_FILE=$(find ./package/lean/autocore/ -type f -name "index.htm")
	WIFI_FILE="./package/mtk/applications/mtwifi-cfg/files/mtwifi.sh"
	#修改WIFI名称
	sed -i "s/ImmortalWrt/$WRT_SSID/g" $WIFI_FILE
	#修改WIFI加密
	sed -i "s/encryption=.*/encryption='psk2+ccmp'/g" $WIFI_FILE
	#修改WIFI密码
	sed -i "/set wireless.default_\${dev}.encryption='psk2+ccmp'/a \\\t\t\t\t\t\set wireless.default_\${dev}.key='$WRT_WORD'" $WIFI_FILE

	# 修改版本为编译日期
	date_version=$(date +"%y.%m.%d")
	orig_version=$(cat "package/emortal/default-settings/files/99-default-settings-chinese" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
	sed -i "s/${orig_version}/R${date_version} by vx:Mr___zjz/g" package/emortal/default-settings/files/99-default-settings-chinese
	#修复软件源的问题
	#sed -i "s,7981/packages,filogic/packages,g" /etc/opkg/distfeeds.conf
	
	# 添加两行代码到 exit 0 前面
	sed -i '/^exit 0$/i sed -i "s,7981/packages,filogic/packages,g" /etc/opkg/distfeeds.conf' package/emortal/default-settings/files/99-default-settings-chinese

fi



CFG_FILE="./package/base-files/files/bin/config_generate"
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
if [[ $WRT_URL == *"lede"* ]]; then
	LEDE_FILE=$(find ./package/lean/autocore/ -type f -name "index.htm")
	#修改默认时间格式
	sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M 星期%w")/g' $LEDE_FILE
	# 注释原行（精确匹配原URL和版本）
	#sed -i '/src-git luci https:\/\/github.com\/coolsnowwolf\/luci\.git;openwrt-23.05/s/^/#/' "feeds.conf.default"
	# 添加新行到文件末尾

	#24.1 uci
	#echo "src-git luci https://github.com/coolsnowwolf/luci.git;openwrt-24.10" >> "feeds.conf.default"
	
	#echo "src-git luci https://github.com/coolsnowwolf/luci.git" >> "feeds.conf.default"
	# 修改版本为编译日期
	date_version=$(date +"%y.%m.%d")
	orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
	sed -i "s/${orig_version}/R${date_version} by vx:Mr___zjz/g" package/lean/default-settings/files/zzz-default-settings
	#添加软件源


fi

#添加第三方软件源
sed -i "s/option check_signature/# option check_signature/g" package/system/opkg/Makefile
echo src/gz openwrt_kiddin9 https://dl.openwrt.ai/latest/packages/aarch64_cortex-a53/kiddin9 >> ./package/system/opkg/files/customfeeds.conf


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
