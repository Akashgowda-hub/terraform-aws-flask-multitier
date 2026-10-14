#!/bin/bash
set -Eeuo pipefail

APP_DIR="/opt/flaskapp/01-tier-monolith"
VENV_DIR="/opt/flaskapp/venv"
SERVICE_FILE="/etc/systemd/system/flaskapp.service"

echo "Starting application deployment..."

# 1. Verify required commands and application files
command -v python3 >/dev/null
test -f "$APP_DIR/app/requirements.txt"
test -f "$APP_DIR/Scripts/flaskapp.service"

# 2. Create the virtual environment and install dependencies
python3 -m venv "$VENV_DIR"
"$VENV_DIR/bin/python" -m pip install --upgrade pip
"$VENV_DIR/bin/python" -m pip install -r "$APP_DIR/app/requirements.txt"

# 3. Initialize the database table before starting the application
cd "$APP_DIR/app"

"$VENV_DIR/bin/python" -c '
from app import get_db_connection

conn = get_db_connection()
try:
    with conn.cursor() as cur:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS todos (
                id SERIAL PRIMARY KEY,
                task VARCHAR(255) NOT NULL
            );
        """)
    conn.commit()
    print("Database initialized successfully.")
finally:
    conn.close()
'

# 4. Install and start the systemd service
install -m 0644 "$APP_DIR/Scripts/flaskapp.service" "$SERVICE_FILE"
systemctl daemon-reload
systemctl enable flaskapp
systemctl restart flaskapp

# 5. Confirm the service started successfully
systemctl is-active --quiet flaskapp
echo "Application deployment completed successfully."
