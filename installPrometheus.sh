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

echo "[Unit]" >> /etc/systemd/system/prometheus.service
echo "Description=Prometheus Service" >> /etc/systemd/system/prometheus.service
echo "After=network.target" >> /etc/systemd/system/prometheus.service
echo "[Service]" >> /etc/systemd/system/prometheus.service
echo "User=prometheus" >> /etc/systemd/system/prometheus.service
echo "Group=prometheus" >> /etc/systemd/system/prometheus.service
echo "Type=simple" >> /etc/systemd/system/prometheus.service
echo "ExecStart=/usr/local/bin/prometheus \" >> /etc/systemd/system/prometheus.service
echo "--config.file /etc/prometheus/prometheus.yml \" >> /etc/systemd/system/prometheus.service
echo "--storage.tsdb.path /var/lib/prometheus/ \" >> /etc/systemd/system/prometheus.service
echo "--web.console.templates=/etc/prometheus/consoles \" >> /etc/systemd/system/prometheus.service
echo "--web.console.libraries=/etc/prometheus/console_libraries" >> /etc/systemd/system/prometheus.service
echo "ExecReload=/bin/kill -HUP $MAINPID" >> /etc/systemd/system/prometheus.service
echo "Restart=on-failure" >> /etc/systemd/system/prometheus.service
echo "[Install]" >> /etc/systemd/system/prometheus.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/prometheus.service

systemctl daemon-reload
systemctl enable prometheus
chown -R prometheus:prometheus /var/lib/prometheus

/usr/local/bin/prometheus
--config.file /etc/prometheus/prometheus.yml
--storage.tsdb.path /var/lib/prometheus/
--web.console.templates=/etc/prometheus/consoles
--web.console.libraries=/etc/prometheus/console_libraries

systemctl start prometheus
systemctl status prometheus

