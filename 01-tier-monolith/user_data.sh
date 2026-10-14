#!/bin/bash
set -Eeuo pipefail

export DEBIAN_FRONTEND=noninteractive

APP_REPO="https://github.com/Akashgowda-hub/terraform-aws-flask-multitier.git"
APP_DIR="/opt/flaskapp"

echo "Installing system packages..."
apt-get update -y
apt-get install -y \
    git \
    python3 \
    python3-venv \
    python3-pip \
    postgresql \
    postgresql-contrib

echo "Starting PostgreSQL..."
systemctl enable --now postgresql

# Wait for PostgreSQL to accept connections (maximum 60 seconds).
for attempt in $(seq 1 60); do
    if pg_isready -q; then
        break
    fi
    if [ "$attempt" -eq 60 ]; then
        echo "ERROR: PostgreSQL did not become ready."
        exit 1
    fi
    sleep 1
done

echo "Configuring application database..."

# Create the database if it does not already exist.
if ! sudo -u postgres psql -tAc \
    "SELECT 1 FROM pg_database WHERE datname = 'flaskdb'" | grep -q 1; then
    sudo -u postgres createdb flaskdb
fi

# Create the application role if needed, then ensure its password is current.
sudo -u postgres psql -v ON_ERROR_STOP=1 <<'SQL'
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'flaskuser') THEN
        CREATE ROLE flaskuser LOGIN;
    END IF;
END
$$;

ALTER ROLE flaskuser WITH LOGIN PASSWORD 'flaskpass123';
GRANT CONNECT, TEMPORARY ON DATABASE flaskdb TO flaskuser;
SQL

sudo -u postgres psql -v ON_ERROR_STOP=1 -d flaskdb \
    -c "GRANT ALL ON SCHEMA public TO flaskuser;"

echo "Cloning application repository..."

if [ ! -d "$APP_DIR/.git" ]; then
    git clone "$APP_REPO" "$APP_DIR"
else
    echo "Repository already exists; skipping clone."
fi

echo "Running application deployment..."
cd "$APP_DIR/01-tier-monolith"
bash Scripts/deploy.sh

echo "EC2 initialization completed successfully."
