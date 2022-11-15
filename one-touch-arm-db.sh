#!/bin/bash
set -ex

WORKSPACE=/opt/ServerStatus
mkdir -p ${WORKSPACE}
cd ${WORKSPACE}
apt-get update
apt-get upgrade
apt-get install build-essential gcc make perl dkms
# yum install -y sqlite-devel
### apt-get install libsqlite3-dev
apt-get install -y libsqlite3-dev
# yum -y install gcc gcc-c++
apt install 'g++'
apt-get install build-essential

apt-get install wget

apt-get install curl

apt-get install unzip

wget https://humdi.net/vnstat/vnstat-latest.tar.gz
tar zxvf vnstat-latest.tar.gz
# cd vnstat-*
cd vnstat-2.10
./configure --prefix=/usr --sysconfdir=/etc && make && make install
# ./configure --prefix=/usr/local --sysconfdir=/etc && make && make install
vnstatd -d
cp -v examples/systemd/vnstat.service /etc/systemd/system/
systemctl enable vnstat
systemctl start vnstat

#初始化文件

# Debian
cp -v examples/init.d/debian/vnstat /etc/init.d/
update-rc.d vnstat defaults
service vnstat start

# 红帽/CentOS
# cp -v examples/init.d/redhat/vnstat /etc/init.d/
# chkconfig vnstat on
# service vnstat start

cd ${WORKSPACE}
# 下载, arm 机器替换 x86_64 为 aarch64
OS_ARCH="x86_64"
latest_version=$(curl -m 10 -sL "https://api.github.com/repos/zdz/ServerStatus-Rust/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')

wget --no-check-certificate -qO "server-${OS_ARCH}-unknown-linux-musl.zip"  "https://github.com/zdz/ServerStatus-Rust/releases/download/${latest_version}/server-${OS_ARCH}-unknown-linux-musl.zip"
wget --no-check-certificate -qO "client-${OS_ARCH}-unknown-linux-musl.zip"  "https://github.com/zdz/ServerStatus-Rust/releases/download/${latest_version}/client-${OS_ARCH}-unknown-linux-musl.zip"

unzip -o "server-${OS_ARCH}-unknown-linux-musl.zip"
unzip -o "client-${OS_ARCH}-unknown-linux-musl.zip"

# systemd service
mv -v stat_server.service /etc/systemd/system/stat_server.service
mv -v stat_client.service /etc/systemd/system/stat_client.service

systemctl daemon-reload

# 启动
# systemctl start stat_server
# systemctl start stat_client

# 状态查看
## systemctl status stat_server
# systemctl status stat_client

# 使用以下命令开机自启
# systemctl enable stat_server
# systemctl enable stat_client

# 停止
# systemctl stop stat_server
# systemctl stop stat_client

# https://fedoraproject.org/wiki/Systemd/zh-cn
# https://docs.fedoraproject.org/en-US/quick-docs/understanding-and-administering-systemd/index.html

# 修改 /etc/systemd/system/stat_client.service 文件，将IP改为你服务器的IP或你的域名one-touch.sh
