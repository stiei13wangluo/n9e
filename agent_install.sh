#!/bin/bash

server_ip="192.168.30.196"
ip=$(ifconfig `route|grep '^default'|awk '{print $NF}'`|grep inet|awk '{print $2}'|head -n 1|awk -F':' '{print $NF}')
if [ $? -ne 0 ];then
echo "获取IP失败
清执行ifconfig \`route|grep '^default'|awk '{print \$NF}'\`|grep inet|awk '{print \$2}'|head -n 1|awk -F':' '{print \$NF}'
结果是否为机器IP"
exit
else
mkdir /tmp/n9e
cd /tmp/n9e
wget http://116.85.64.82/n9e-3.6.0.tar.gz
tar -zxvf n9e-3.6.0.tar.gz
mkdir -pv /home/n9e/etc
cp n9e-agent control /home/n9e/
cp etc/agent.yml  etc/identity.yml etc/address.yml /home/n9e/etc
cd /home/n9e
fi
sed -i 's/specify: ""/specify: "'$(echo $ip)'"/g' etc/identity.yml
sed -i 's/- 127.0.0.1/- '$(echo $server_ip)'/g' etc/address.yml

cat >> /usr/lib/systemd/system/n9e-agent.service <<EOF
[Unit]
Description=n9e agent
After=network-online.target
Wants=network-online.target

[Service]
# modify when deploy in prod env
User=root
Group=root

Type=simple
Environment="GIN_MODE=release"
ExecStart=/home/n9e/n9e-agent
WorkingDirectory=/home/n9e/

Restart=always
RestartSec=1
StartLimitInterval=0

[Install]
WantedBy=multi-user.target
EOF
systemctl enable n9e-agent.service
systemctl start n9e-agent.service
echo "执行成功"