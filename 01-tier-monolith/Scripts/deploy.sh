#!/bin/bash
set -e

echo "Starting application deployment..."

# 1. Setup Python Virtual Environment
python3.12 -m venv /opt/flaskapp/venv
/opt/flaskapp/venv/bin/pip install --upgrade pip
/opt/flaskapp/venv/bin/pip install -r /opt/flaskapp/01-tier-monolith/app/requirements.txt

# 2. Configure Systemd Service using the file tracked in git
cp /opt/flaskapp/01-tier-monolith/Scripts/flaskapp.service /etc/systemd/system/flaskapp.service

systemctl daemon-reload
systemctl restart flaskapp
systemctl enable flaskapp

# 3. Initialize Database Table via Python Runtime
/opt/flaskapp/venv/bin/python3 -c "
import sys
sys.path.append('/opt/flaskapp/01-tier-monolith/app')
from app import get_db_connection
try:
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('CREATE TABLE IF NOT EXISTS todos (id SERIAL PRIMARY KEY, task VARCHAR(255) NOT NULL);')
    conn.commit()
    cur.close()
    conn.close()
    print('Database initialized successfully.')
except Exception as e:
    print(f'DB Init failed: {e}')
"