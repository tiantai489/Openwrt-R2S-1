#!/bin/bash
clear
export TERM=linux
#进入friendlywrt目录
cd friendlywrt-rk3328/friendlywrt/
#增加防掉线脚本
mv ../../script/check_inet.sh package/base-files/files/usr/bin/ && chmod +x package/base-files/files/usr/bin/check_inet.sh
mv ../../script/check package/base-files/files/etc/init.d/ && chmod +x package/base-files/files/etc/init.d/check
#刷机脚本
mv ../../script/update.sh package/base-files/files/root/update.sh && chmod +x package/base-files/files/root/update.sh
#修改版本号
sed -i 's/OpenWrt/Quintus Build @ $(date "+%Y.%m.%d")/g' package/lean/default-settings/files/zzz-default-settings
echo -e '\nQuintus Build\n'  >> package/base-files/files/etc/banner
#生成时间
VersionDate=$(git show -s --date=short --format="%cd")
echo "::set-env name=VersionDate::$VersionDate"
echo "::set-env name=DATE::$(date "+%Y-%m-%d %H:%M:%S")"
#改为Ofast make coremark，跑分
sed -i 's,-DMULTIT,-Ofast -DMULTIT,g' package/lean/coremark/Makefile
#更新替换软件包
rm -rf package/lean/luci-theme-opentomcat
rm -rf package/lean/luci-app-frpc
rm -rf package/lean/luci-app-frps
rm -rf package/lean/luci-app-diskman
#rm -rf package/lean/luci-app-samba4
#rm -rf package/lean/samba4
#rm -rf package/feeds/packages/ttyd
#rm -rf package/lean/luci-app-ttyd
#rm -rf package/lean/luci-app-zerotier
#git clone https://github.com/rufengsuixing/luci-app-zerotier.git package/lean/luci-app-zerotier
git clone https://github.com/Leo-Jo-My/luci-theme-opentomcat.git package/lean/luci-theme-opentomcat
git clone https://github.com/lwz322/luci-app-frps.git package/lean/luci-app-frps
git clone https://github.com/kuoruan/luci-app-frpc.git package/lean/luci-app-frpc
#git clone https://github.com/lisaac/luci-app-diskman.git package/lean/luci-app-diskman
svn co https://github.com/songchenwen/nanopi-r2s/trunk/luci-app-r2sflasher package/luci-app-r2sflasher
svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/gost package/gost
git clone https://github.com/lisaac/luci-app-dockerman.git package/lean/luci-app-dockerman
#svn co https://github.com/openwrt/luci/trunk/applications/luci-app-samba4 package/lean/luci-app-samba4
#svn co https://github.com/openwrt/packages/trunk/net/samba4 package/lean/samba4
#svn co https://github.com/openwrt/packages/trunk/utils/ttyd package/ttyd
#svn co https://github.com/openwrt/luci/trunk/applications/luci-app-ttyd package/luci-app-ttyd

#更改默認主題及界面语言
sed -i '/uci commit luci/i\uci set luci.main.mediaurlbase="/luci-static/opentomcat"' package/lean/default-settings/files/zzz-default-settings
sed -i 's/luci.main.lang=zh_cn/luci.main.lang=auto/g' package/lean/default-settings/files/zzz-default-settings

#關閉wan外部傳入及轉發
sed -i '/firewall/d' ../device/friendlyelec/rk3328/default-settings/install.sh
#只允許ssh在lan內部連接
sed -i '/uci commit luci/a\uci commit dropbear' package/lean/default-settings/files/zzz-default-settings
sed -i '/uci commit luci/a\uci set dropbear.@dropbear[0].Interface='lan'' package/lean/default-settings/files/zzz-default-settings
#关闭ipv6
sed -i '/uci commit/i\uci delete network.lan.ip6assign' package/base-files/files/root/setup.sh
sed -i '/uci commit/i\uci delete network.wan6' package/base-files/files/root/setup.sh
sed -i '/uci commit/i\uci delete dhcp.lan.ra' package/base-files/files/root/setup.sh
sed -i '/uci commit/i\uci delete dhcp.lan.dhcpv6' package/base-files/files/root/setup.sh
sed -i '/uci commit/i\uci delete dhcp.lan.ndp' package/base-files/files/root/setup.sh
#默认dnsmasq-full
sed -i 's/dnsmasq /dnsmasq-full default-settings luci /' include/target.mk
#增加最大连接
sed -i 's/16384/65536/g' package/kernel/linux/files/sysctl-nf-conntrack.conf
#install upx
mkdir -p staging_dir/host/bin/
ln -s /usr/bin/upx-ucl staging_dir/host/bin/upx
exit 0
