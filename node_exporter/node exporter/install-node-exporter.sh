!#/bin/bash

sudo useradd --no-create-home node_exporter

sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
sudo tar xzf node_exporter-1.7.0.linux-amd64.tar.gz
sudo cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/node_exporter
sudo rm -rf node_exporter-1.7.0.linux-amd64.tar.gz 

sudo cp node-exporter.service /etc/systemd/system/node-exporter.service

sudo systemctl daemon-reload
sudo systemctl enable node-exporter
sudo systemctl start node-exporter
sudo systemctl status node-exporter
