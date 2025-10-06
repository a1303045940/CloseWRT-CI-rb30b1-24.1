#!/bin/bash

PKG_PATH="$GITHUB_WORKSPACE/wrt/package/"



#修改argon主题字体和颜色
#if [ -d *"luci-theme-argon"* ]; then
#	#echo " "

#	#cd ./luci-theme-argon/

#	#sed -i "/font-weight:/ { /important/! { /\/\*/! s/:.*/: var(--font-weight);/ } }" $(find ./luci-theme-argon -type f -iname "*.css")
#	#sed -i "s/primary '.*'/primary '#31a1a1'/; s/'0.2'/'0.5'/; s/'none'/'bing'/; s/'600'/'normal'/" ./luci-app-argon-config/root/etc/config/argon

#	#cd $PKG_PATH && echo "theme-argon has been fixed!"
#fi

#修改qca-nss-drv启动顺序
NSS_DRV="../feeds/nss_packages/qca-nss-drv/files/qca-nss-drv.init"
if [ -f "$NSS_DRV" ]; then
	echo " "

	sed -i 's/START=.*/START=85/g' $NSS_DRV

	cd $PKG_PATH && echo "qca-nss-drv has been fixed!"
fi

#修改qca-nss-pbuf启动顺序
NSS_PBUF="./kernel/mac80211/files/qca-nss-pbuf.init"
if [ -f "$NSS_PBUF" ]; then
	echo " "

	sed -i 's/START=.*/START=86/g' $NSS_PBUF

	cd $PKG_PATH && echo "qca-nss-pbuf has been fixed!"
fi

# 更新 Golang 为最新版
cd "$pkgPath"
rm -rf "$WRT_MainPath/feeds/packages/lang/golang"
git clone https://github.com/sbwml/packages_lang_golang -b 25.x "$WRT_MainPath/feeds/packages/lang/golang"
echo 'Updated: golang'
echo ''


#修复TailScale配置文件冲突
#TS_FILE=$(find ../feeds/packages/ -maxdepth 3 -type f -wholename "*/tailscale/Makefile")
#if [ -f "$TS_FILE" ]; then
#	echo " "

#	sed -i '/\/files/d' $TS_FILE

#	cd $PKG_PATH && echo "tailscale has been fixed!"
#fi

#预置OpenClash内核和数据
if [ -d *"openclash"* ]; then
        echo "预置OpenClash内核和数据!"
	CORE_VER="https://raw.githubusercontent.com/vernesong/OpenClash/core/dev/core_version"
	CORE_TYPE=$(echo $WRT_TARGET | grep -Eiq "64|86" && echo "amd64" || echo "arm64")
	CORE_TUN_VER=$(curl -sL $CORE_VER | sed -n "2{s/\r$//;p;q}")

	CORE_DEV="https://github.com/vernesong/OpenClash/raw/core/dev/dev/clash-linux-$CORE_TYPE.tar.gz"
	CORE_MATE="https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-$CORE_TYPE.tar.gz"
	CORE_TUN="https://github.com/vernesong/OpenClash/raw/core/dev/premium/clash-linux-$CORE_TYPE-$CORE_TUN_VER.gz"

	GEO_MMDB="https://github.com/alecthw/mmdb_china_ip_list/raw/release/lite/Country.mmdb"
	GEO_SITE="https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat"
	GEO_IP="https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat"

	cd ./luci-app-openclash/root/etc/openclash/

	curl -sL -o Country.mmdb $GEO_MMDB && echo "Country.mmdb done!"
	curl -sL -o GeoSite.dat $GEO_SITE && echo "GeoSite.dat done!"
	#curl -sL -o GeoIP.dat $GEO_IP && echo "GeoIP.dat done!"

	mkdir ./core/ && cd ./core/

	curl -sL -o meta.tar.gz $CORE_MATE && tar -zxf meta.tar.gz && mv -f clash clash_meta && echo "meta done!"
	#curl -sL -o tun.gz $CORE_TUN && gzip -d tun.gz && mv -f tun clash_tun && echo "tun done!"
	#curl -sL -o dev.tar.gz $CORE_DEV && tar -zxf dev.tar.gz && echo "dev done!"

	chmod +x ./* && rm -rf ./*.gz

	cd $PKG_PATCH && echo "openclash date has been updated!"
fi

#修复Rust编译失败
RUST_FILE=$(find ../feeds/packages/ -maxdepth 3 -type f -wholename "*/rust/Makefile")
if [ -f "$RUST_FILE" ]; then
	echo " "

	sed -i 's/ci-llvm=true/ci-llvm=false/g' $RUST_FILE

	cd $PKG_PATH && echo "rust has been fixed!"
fi

filetype=$(file "$1")
if echo "$filetype" | grep -q 'shared object'; then
    echo "$1: shared object"
    # 跳过 strip
    exit 0
fi
#移除sb内核回溯移植补丁
#SB_PATCH="../feeds/packages/net/sing-box/patches"
#if [ -d "$SB_PATCH" ]; then
#	echo " "

#	rm -rf $SB_PATCH

#	cd $PKG_PATH && echo "sing-box patches has been fixed!"
#fi
