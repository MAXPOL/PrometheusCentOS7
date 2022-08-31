#! /bin/bash

cd /

yum install chrony -y
systemctl enable chronyd
systemctl start chronyd

iptables -I INPUT 1 -p tcp --match multiport --dports 9090,9093,9094,9100 -j ACCEPT
iptables -A INPUT -p udp --dport 9094 -j ACCEPT

wget https://github.com/prometheus/prometheus/releases/download/v2.38.0/prometheus-2.38.0.linux-amd64.tar.gz
mkdir /etc/prometheus
mkdir /var/lib/prometheus

tar zxvf prometheus-*.linux-amd64.tar.gz
cd prometheus-*.linux-amd64
cp prometheus promtool /usr/local/bin/
cp -r console_libraries consoles prometheus.yml /etc/prometheus

useradd --no-create-home --shell /bin/false prometheus
chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}

/usr/local/bin/prometheus
--config.file /etc/prometheus/prometheus.yml
--storage.tsdb.path /var/lib/prometheus/
--web.console.templates=/etc/prometheus/consoles
--web.console.libraries=/etc/prometheus/console_libraries
