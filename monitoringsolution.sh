
#this file and bastionconf.sh both are same 

#!/bin/bash

set -e

# Check if running with root privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Update system packages and install necessary dependencies
apt-get update -y
apt-get install -y wget tar

# Create Prometheus user and necessary directories
useradd --no-create-home --shell /bin/false prometheus
mkdir -p /etc/prometheus /var/lib/prometheus /opt/prometheus

# Download and extract Prometheus
PROMETHEUS_VERSION="2.26.0"
cd /opt/prometheus
wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
tar -xvf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz --strip-components=1

# Set ownership and permissions
chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus /opt/prometheus
chmod -R 755 /var/lib/prometheus

# Create Prometheus service file
cat > /etc/systemd/system/prometheus.service << EOL
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/opt/prometheus/prometheus \
        --config.file /etc/prometheus/prometheus.yml \
        --storage.tsdb.path /var/lib/prometheus/ \
        --web.console.templates=/etc/prometheus/consoles \
        --web.console.libraries=/etc/prometheus/console_libraries \
        --web.listen-address=0.0.0.0:9090
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and start Prometheus
systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus

echo "Prometheus installation completed."

# Install Node Exporter
NODE_EXPORTER_VERSION="1.3.1"
cd /opt
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
tar xvf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin
rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64
useradd --no-create-home --shell /bin/false node_exporter
chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Create Node Exporter service file
cat > /etc/systemd/system/node_exporter.service << EOL
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and start Node Exporter
systemctl daemon-reload
systemctl start node_exporter

echo "Node Exporter installation completed."

# Install Docker
apt-get install -y docker.io

# Pull and run Grafana container
docker pull grafana/grafana
docker run -d -p 3000:3000 --name=grafana grafana/grafana

echo "Grafana installation completed."

# Open necessary firewall ports
ufw allow 9090/tcp
ufw allow 3000/tcp

echo "Script execution completed."

