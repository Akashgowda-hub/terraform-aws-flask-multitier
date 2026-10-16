
#!/bin/bash
set -Eeuo pipefail

exec > >(tee -a /var/log/user-data-flaskapp.log) 2>&1

echo "Starting 2-tier Todo application setup..."

apt-get update -y
apt-get install -y git python3 python3-venv python3-pip

systemctl enable --now network-online.target

# Clone the committed application code.
git clone --depth 1 --branch main \
  https://github.com/Akashgowda-hub/terraform-aws-flask-multitier.git \
  /opt/flaskapp

# Create a Python virtual environment and install dependencies.
python3 -m venv /opt/flaskapp/venv

/opt/flaskapp/venv/bin/python -m pip install --upgrade pip

/opt/flaskapp/venv/bin/python -m pip install \
  -r /opt/flaskapp/02-tier-rds/app/requirements.txt

# Store connection settings in a root-readable environment file.
cat > /etc/flaskapp.env <<'ENV'
DB_HOST=${db_host}
DB_NAME=${db_name}
DB_USER=${db_username}
DB_PASS=${db_password}
ENV

chmod 600 /etc/flaskapp.env

# Load the database configuration for the initialization command.
set -a
source /etc/flaskapp.env
set +a

cd /opt/flaskapp/02-tier-rds/app

# Retry database initialization because RDS may need time to accept connections.
 /opt/flaskapp/venv/bin/python - <<'PY'
import time
from app import get_db_connection

last_error = None

for attempt in range(1, 31):
    conn = None
    try:
        conn = get_db_connection()
        with conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS todos (
                    id SERIAL PRIMARY KEY,
                    task VARCHAR(255) NOT NULL
                );
            """)
        conn.commit()
        print("Database table initialized successfully.")
        break
    except Exception as exc:
        last_error = exc
        print(f"Database attempt {attempt}/30 failed: {exc}")
        time.sleep(5)
    finally:
        if conn is not None:
            conn.close()
else:
    raise SystemExit(f"Could not initialize database: {last_error}")
PY

# Create a dedicated, non-root application user.
useradd --system --home /opt/flaskapp \
  --shell /usr/sbin/nologin flaskapp

chown -R flaskapp:flaskapp \
  /opt/flaskapp/02-tier-rds/app \
  /opt/flaskapp/venv

# Configure systemd.
cat > /etc/systemd/system/flaskapp.service <<'SERVICE'
[Unit]
Description=Flask Todo Application - 2 Tier
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=flaskapp
Group=flaskapp
WorkingDirectory=/opt/flaskapp/02-tier-rds/app
EnvironmentFile=/etc/flaskapp.env
ExecStart=/opt/flaskapp/venv/bin/gunicorn --workers 2 --bind 0.0.0.0:5000 app:app
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable --now flaskapp

echo "2-tier Todo application setup completed."
