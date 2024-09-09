# Prometheus And Grafana Configuration


- Prometheus is an open source tool for monitoring and alerting applications

- A multi-dimensional data model with time series data identified by metric name and key/value pairs

- Uses PromQL ( Prometheus Query Language)

- Time series collection happens via a pull model over HTTP

- Targets System which you want to monitor can be identified using Service Discovery or by static configuration in the yaml file


**Prometheus Server**: This component is the central component that collects the metrics from multiple nodes. Prometheus uses the concept of scraping, where target systems’ metric endpoints are contacted to fetch data at regular intervals.

**Node Exporter**: This is called a monitoring agent which we installed on all the target machines so that Prometheus can fetch the data from all the metrics endpoints

**Push Gateway**: Push Gateway is used for scraping metrics from applications and passing on the data to Prometheus. Push Gateway captures the data and then transforms it into the Prometheus data format before pushing.

**Alert Manager**: Alert Manager is used to send the various alerts based upon the metrics data collected in Prometheus.

**Web UI**: The web UI layer of Prometheus provides the end user with an interface to visualize data collected by Prometheus. In this, we will use Grafana to visualize the data.


## Getting started

Security Groups Configured on EC2 Instances

Port **9090** — Prometheus Server

Port **9100** — Prometheus Node Exporter

Port **3000** — Grafana


## Important Note

Before diving into the installation process, we have already completed the required configurations in the Prometheus server. **Therefore, do not upgrade the versions of Prometheus and Grafana.**


## Install Prometheus

Now we will install the Prometheus on one of the EC2 Instance.

- Clone the git repository and install only the version shared within the repository.

- Run the **install-prometheus.sh** script

- This script will install everything and configured it.

- This script will do the below steps:


1. Create a new user and add new directories

```
sudo useradd --no-create-home prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

```
2. Download the Prometheus, extract it and put it in **/usr/local/bin/** folder and finally delete the software

```
wget  https://gitlab.beinex.in/devops/prometheus.git/prometheus-2.45.3.linux-amd64.tar.gz

```

```
tar -xvf prometheus-2.45.3.linux-amd64.tar.gz
sudo cp prometheus-2.45.3.linux-amd64/prometheus /usr/local/bin
sudo cp prometheus-2.45.3.linux-amd64/promtool /usr/local/bin

sudo cp -r prometheus-2.45.3.linux-amd64/consoles /etc/prometheus/
sudo cp -r prometheus-2.45.3.linux-amd64/console_libraries /etc/prometheus
sudo cp prometheus-2.45.3.linux-amd64/promtool /usr/local/bin/
rm -rf prometheus-2.45.3.linux-amd64.tar.gz prometheus-2.45.3.linux-amd64
```

3. Now we will configure Prometheus to monitor itself using yaml file. Create a prometheus.yml file at /etc/prometheus/prometheus.yml (**The file already exists at the specified path, and no changes should ever be made to this file.**)

4. Now we want to run the Prometheus as a Service so that in case of server restart service will come automatically.

Let’s create a file **/etc/systemd/system/prometheus.service** with the below content:(**The file already exists at the specified path, and no changes should ever be made to this file.**)

```
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
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
```

5. Change the ownership of all folders and files which we have created to the user which we have created in the first step

```
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

sudo chown -R prometheus:prometheus /etc/prometheus/consoles

sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
sudo chown -R prometheus:prometheus /var/lib/prometheus
```

6. Now we will configure the service and start it

```
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
sudo systemctl status prometheus
```

Now open it on the browser using below url: 

- Aurex: prom-aurex.beinex.com

- Digital: prom-digital.beinex.com


**If you are not able to access it then make sure your security group is configured for port 9090 and its open from your IP.**


## Install Node Exporter in Linux Servers

Now to monitor your servers you need to install the node exporter on all your target machine which is like a monitoring agent on all the servers.

You can clone this repo and run it directly using below command

```
./install-node-exporter.sh
```

This script will do the below steps:

It will create a new user , download the software using wget and then run the node-exporter as a service

```
sudo useradd --no-create-home node_exporter
```
```
sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
sudo tar xzf node_exporter-1.7.0.linux-amd64.tar.gz
sudo cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/node_exporter
sudo rm -rf node_exporter-1.7.0.linux-amd64.tar.gz 
```
```
sudo cp node-exporter.service /etc/systemd/system/node-exporter.service
```
```
sudo systemctl daemon-reload
sudo systemctl enable node-exporter
sudo systemctl start node-exporter
sudo systemctl status node-exporter
```

**Make sure port 9100 is open from your IP to access this url. You should be able to access all the metrics which is coming from this server.**


## Install Windows Exporter in Windows Servers

1. Log on to the Windows instance as an administrator.

2. Download the Windows Exporter package to the ECS instance.

3. Double-click the installation package **windows_exporter-0.25.1-amd64.msi** downloaded in the previous step, or run the msiexec /i windows_exporter-1.19.0-amd64.msi command to install Windows Exporter.

4. After Windows Exporter is installed, you can see the created services in the Windows Services console, including Windows Exporter.


## Install Windows Exporter Using SSM/Powershell.

1. Log in to the SSM/Powershell of the server and navigate to Powershell.

```
cd '.\Program Files\'
```
2. Create a new directory named "windows-exporter".

```
New-Item windows-exporter -ItemType Directory
```

3. Navigate to the created directory.

```
cd windows-exporter
```

4. Download the windows_exporter-0.25.1-amd64.msi using the following command.

```
Invoke-WebRequest -Uri "https://github.com/prometheus-community/windows_exporter/releases/download/v0.25.1/windows_exporter-0.25.1-amd64.msi" -OutFile "windows_exporter-0.25.1-amd64.msi"
```

5. Once the download is completed, run the following command.

```
Start-Process -FilePath "windows_exporter-0.25.1-amd64.msi" -ArgumentList "/qn" -Wait
```

**Make sure port 9182 is open from your IP to access this url. You should be able to access all the metrics which is coming from this server.**


## Prometheus Service Discovery on EC2 Instance

Now we will use Service discovery so that we don’t need to change the Prometheus configuration for each of the instance.

Specify the AWS region and use IAM user API key which has EC2ReadyOnlyAccess . If there is no user available then you can create one.

**We have already configured the /etc/prometheus/prometheus.yml file as required, so there is no need to make any further changes to it.**

Restart the service incase if you made any changes.

```
sudo systemctl restart prometheus
sudo systemctl status prometheus
```

This is how you can use the Service discovery in Prometheus for all the EC2 instances.


## Install Grafana

Once Prometheus is installed successfully then we can install the Grafana and configure Prometheus as a datasource.

Grafana is an opensource tool which is used to provide the visualization of your metrics.

Steps to Install

1. Clone this git repo
2. Run the below file

```
./install-grafana.sh
```

This script will do the below steps:

It will download the software using wget and then run the grafana as a service

```
sudo apt-get install -y adduser libfontconfig1
wget https://gitlab.beinex.in/devops/prometheus.git/grafana-enterprise_10.4.0_amd64.deb
sudo dpkg -i grafana-enterprise_10.4.0_amd64.deb
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl status grafana-server
sudo systemctl enable grafana-server.service
```

Now open it on the browser using below url:

Make sure that port 3000 is open for this instance.

Login with username : **devops** and password **heatRonOMF**


We have already added the data source and created dashboards for both Aurex and Digital servers. You can begin monitoring the dashboard by accessing the URL.
