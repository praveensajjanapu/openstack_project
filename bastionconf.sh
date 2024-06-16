#!/bin/bash

apt update -y
export RELEASE="2.2.1"

# Create users if they don't already exist
if ! id "prometheus" &>/dev/null; then
    useradd --no-create-home --shell /bin/false prometheus
fi

if ! id "node_exporter" &>/dev/null; then
    useradd --no-create-home --shell /bin/false node_exporter
fi

# Create directories if they don't already exist
[ ! -d /etc/prometheus ] && mkdir /etc/prometheus
[ ! -d /var/lib/prometheus ] && mkdir /var/lib/prometheus

chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

# Stop Prometheus if it's running
if systemctl is-active --quiet prometheus; then
    systemctl stop prometheus
fi

# Download Prometheus
cd /opt/
PROMETHEUS_VERSION="2.26.0"
PROMETHEUS_FILE="prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz"
PROMETHEUS_URL="https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/$PROMETHEUS_FILE"

if [ ! -f $PROMETHEUS_FILE ]; then
    wget $PROMETHEUS_URL
    sha256sum $PROMETHEUS_FILE
    tar -xvf $PROMETHEUS_FILE
fi

cd prometheus-$PROMETHEUS_VERSION.linux-amd64
cp -f prometheus /usr/local/bin/
cp -f promtool /usr/local/bin/

chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

cp -r consoles /etc/prometheus
cp -r console_libraries /etc/prometheus
cp prometheus.yml /etc/prometheus

chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries
chown -R prometheus:prometheus /etc/prometheus/prometheus.yml
chown -R prometheus:prometheus /var/lib/prometheus
chmod -R 755 /var/lib/prometheus

# Start Prometheus
sudo -u prometheus /usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries > /dev/null &

echo "Setting up prometheus.service file"
cat >/etc/systemd/system/prometheus.service <<EOL
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
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

systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus
ufw allow 9090/tcp

# Install and set up Node Exporter
NODE_EXPORTER_VERSION="1.3.1"
NODE_EXPORTER_FILE="node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz"
NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/$NODE_EXPORTER_FILE"

if [ ! -f $NODE_EXPORTER_FILE ]; then
    wget $NODE_EXPORTER_URL
    tar xvf $NODE_EXPORTER_FILE
    cd node_exporter-$NODE_EXPORTER_VERSION.linux-amd64
    cp node_exporter /usr/local/bin
    cd ..
    rm -rf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64
    chown node_exporter:node_exporter /usr/local/bin/node_exporter
fi

echo "Setting up node_exporter.service file"
cat > /etc/systemd/system/node_exporter.service <<EOL
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

systemctl daemon-reload
systemctl start node_exporter

# Install Grafana
apt update -y
apt install docker.io -y

# Stop and remove existing Grafana container if running
if [ $(docker ps -q -f name=grafana) ]; then
    docker stop grafana
    docker rm grafana
fi

docker pull grafana/grafana
docker run -d -p 3000:3000 --name=grafana grafana/grafana

