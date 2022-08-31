#! /bin/bash

cd /

wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0-rc.0/node_exporter-1.4.0-rc.0.linux-amd64.tar.gz
tar zxvf node_exporter-*.linux-amd64.tar.gz
cd node_exporter-*.linux-amd64

cp node_exporter /usr/local/bin/

useradd --no-create-home --shell /bin/false nodeusr

chown -R nodeusr:nodeusr /usr/local/bin/node_exporter

touch /etc/systemd/system/node_exporter.service

echo "[Unit]" >> /etc/systemd/system/node_exporter.service
echo "Description=Node Exporter Service" >> /etc/systemd/system/node_exporter.service
echo "After=network.target" >> /etc/systemd/system/node_exporter.service
echo "[Service]" >> /etc/systemd/system/node_exporter.service
echo "User=nodeusr" >> /etc/systemd/system/node_exporter.service
echo "Group=nodeusr" >> /etc/systemd/system/node_exporter.service
echo "Type=simple" >> /etc/systemd/system/node_exporter.service
echo "ExecStart=/usr/local/bin/node_exporter" >> /etc/systemd/system/node_exporter.service
echo "ExecReload=/bin/kill -HUP $MAINPID" >> /etc/systemd/system/node_exporter.service
echo "Restart=on-failure" >> /etc/systemd/system/node_exporter.service
echo "[Install]" >> /etc/systemd/system/node_exporter.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/node_exporter.service

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter
