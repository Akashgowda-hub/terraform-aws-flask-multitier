import os

import psycopg
from flask import Flask, jsonify, request
from flask_cors import CORS
from psycopg.rows import dict_row

app = Flask(__name__)

FRONTEND_ORIGIN = os.getenv("FRONTEND_ORIGIN", "")

if FRONTEND_ORIGIN:
    CORS(app, resources={
        r"/api/*": {"origins": [FRONTEND_ORIGIN]}
    })


def get_db_connection():
    return psycopg.connect(
        host=os.environ["DB_HOST"],
        dbname=os.getenv("DB_NAME", "flaskdb"),
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASS"],
        connect_timeout=5,
        row_factory=dict_row,
    )


@app.get("/health")
def health():
    return jsonify({"status": "ok"}), 200


@app.get("/api/todos")
def list_todos():
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, title FROM todos ORDER BY id"
            )
            todos = cur.fetchall()

    return jsonify(todos)


@app.post("/api/todos")
def create_todo():
    data = request.get_json(silent=True) or {}
    title = data.get("title")

    if not isinstance(title, str) or not title.strip():
        return jsonify({"error": "A non-empty title is required"}), 400

    title = title.strip()

    if len(title) > 200:
        return jsonify({"error": "Title must be 200 characters or fewer"}), 400

    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO todos (title)
                VALUES (%s)
                RETURNING id, title
                """,
                (title,),
            )
            todo = cur.fetchone()

    return jsonify(todo), 201


@app.delete("/api/todos/<int:todo_id>")
def delete_todo(todo_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "DELETE FROM todos WHERE id = %s RETURNING id",
                (todo_id,),
            )
            deleted = cur.fetchone()

    if deleted is None:
        return jsonify({"error": "Todo not found"}), 404

    return "", 204
