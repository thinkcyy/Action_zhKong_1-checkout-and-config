#!/bin/sh -l
ROUTER_MODEL=$INPUT_ROUTER_MODEL
COMPILE_CONFIG=$INPUT_COMPILE_CONFIG
FILES_CONFIG=$INPUT_FILES_CONFIG

echo -e "Total CPU cores\t: $(nproc)"
cat /proc/cpuinfo | grep 'model name'
ulimit -a 
cat /etc/os-release

swapoff -a
rm -rf /etc/apt/sources.list.d/* /usr/share/dotnet /usr/local/lib/android /opt/ghc
apt-get update && apt-get install -y git
#wget -P /usr/local/sbin/ https://github.com/HiGarfield/lede-17.01.4-Mod/raw/master/.github/backup/apt-fast
#chmod -R 755 /usr/local/sbin/apt-fast
apt-get -y install tree rename zstd dwarves llvm clang lldb lld build-essential rsync asciidoc binutils bzip2 gawk gettext git libncurses5-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc-s1 libc6-dev-i386 subversion flex uglifyjs gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libreadline-dev libglib2.0-dev xmlto qemu-utils upx-ucl libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget ccache curl swig coreutils vim nano python3 python3-pip python3-ply haveged lrzsz scons libpython3-dev
pip3 install pyelftools pylibfdt
apt-get autoremove --purge
apt-get clean
git config --global user.name 'GitHub Actions' && git config --global user.email 'noreply@github.com'
git config --global core.abbrev auto
timedatectl set-timezone "Asia/Shanghai"
df -h

cd /github/workspace/
echo '当前执行步骤：1-下载AgustinLorenzo/openwrt仓库'
git clone --depth 1  https://github.com/thinkcyy/OpenWRT-Action OpenWRT-Action 
git clone --depth 1  https://github.com/AgustinLorenzo/openwrt -b main --single-branch ./OpenWRT-Action/openwrt
#echo "当前工作目录"
#pwd
#tree -L 3

echo '当前执行步骤：2-处理Package'
cd /github/workspace/OpenWRT-Action
chmod +x ./zhKong/scripts/*.sh
cp -vr ./zhKong/config/$INPUT_COMPILE_CONFIG.config ./zhKong/config/config-$INPUT_ROUTER_MODEL.config
./zhKong/scripts/prepare.sh

echo '当前执行步骤：3-处理自定义配置files'
cd /github/workspace/OpenWRT-Action
cp -vr ../openwrt-config/$INPUT_ROUTER_MODEL/files ./openwrt/
chmod +x ./openwrt/files/etc/tinc/tincvpn/tinc-up


echo '当前执行步骤：4-编译'
cd /github/workspace/OpenWRT-Action/openwrt
echo '当前执行步骤：4.1-下载'
make download -j$(nproc)
echo '当前执行步骤：4.2-编译'
make -j$(nproc) || make -j1 V=s

echo '当前执行步骤：5-打标'
if [ $INPUT_FILES_CONFIG != 'public' ] ; then
   tag_name=$INPUT_COMPILE_CONFIG-$INPUT_FILES_CONFIG
else
   tag_name=$INPUT_COMPILE_CONFIG
fi
tag_name=$tag_name-$(date +%Y%m%d-%H%M)
echo $tag_name
         
echo '当前执行步骤：6-组织产出文件'
cd /github/workspace/OpenWRT-Action
rm -rf ./artifact/
mkdir -p ./artifact/
cp -vrf $(find ./openwrt/bin/targets/ -type f -name "*sysupgrade*") ./artifact/
cp -vrf $(find ./openwrt/bin/targets/ -type f -name "*.buildinfo") ./artifact/
cp -r ./openwrt/.config ./artifact/defconfig-$INPUT_COMPILE_CONFIG.config
cd ./artifact/
rename 's/sysupgrade.bin/sysupgrade-$tag_name.bin/' *
ls -Ahl




