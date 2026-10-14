#!/bin/bash
set -e

apt-get update -y
# Added build-essential, libpq-dev, and python3-dev
apt-get install -y git python3 python3-venv python3-dev build-essential libpq-dev postgresql postgresql-contrib

# Start local database (Phase 1 Monolith)
systemctl start postgresql
systemctl enable postgresql
sudo -u postgres psql -c "CREATE DATABASE flaskdb;" || true
sudo -u postgres psql -c "CREATE USER flaskuser WITH PASSWORD 'flaskpass123';" || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE flaskdb TO flaskuser;" || true
sudo -u postgres psql -d flaskdb -c "GRANT ALL ON SCHEMA public TO flaskuser;" || true

# Clone repository to deployment path
git clone https://github.com/Akashgowda-hub/terraform-aws-flask-multitier.git /opt/flaskapp

# Hand off execution to the application's own deployment script
cd /opt/flaskapp/01-tier-monolith
bash Scripts/deploy.sh