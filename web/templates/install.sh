#!/bin/bash
set -x
echo 'Updating image ...'
sudo apt-get update
sudo apt-get upgrade -y
echo 'Installing dependencies ...'
sudo apt-get install -y \
    apt-transport-https \
    build-essential \
    ca-certificates \
    git \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    nginx \
    openjdk-8-jre \
    pgcli \
    postgresql-client \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-venv \
    python3-virtualenv \
    redis-server \
    software-properties-common \
    zlib1g-dev
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo 'deb https://artifacts.elastic.co/packages/6.x/apt stable main' | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
sudo apt-get update
sudo apt-get install elasticsearch -y
echo 'Installing readthedocs ...'
git clone https://github.com/rtfd/readthedocs.org.git ${readthedocs_root}
cd ${readthedocs_root} && git checkout 2.6.2
python3 -m venv ${readthedocs_root}/venv
sudo ${readthedocs_root}/venv/bin/pip3 install -U pip
sudo ${readthedocs_root}/venv/bin/pip3 install -r ${readthedocs_root}/requirements.txt
sudo ln -s /home/admin/configs/local_settings.py ${readthedocs_root}/readthedocs/settings/local_settings.py
sudo ${readthedocs_root}/venv/bin/pip3 install gunicorn pgcli psycopg2-binary
echo 'Installing readthedocs systemd service ...'
sudo ln -s /home/admin/configs/readthedocs.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable readthedocs.service
sudo systemctl start readthedocs.service
echo 'Installing readthedocs nginx site ...'
sudo ln -s /home/admin/configs/readthedocs.nginx /etc/nginx/sites-available/readthedocs
sudo ln -s /etc/nginx/sites-available/readthedocs /etc/nginx/sites-enabled
sudo systemctl restart nginx.service
echo 'Done.'
