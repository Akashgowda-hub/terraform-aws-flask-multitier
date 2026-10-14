import os
import psycopg2
from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "flaskdb")
DB_USER = os.getenv("DB_USER", "flaskuser")
DB_PASS = os.getenv("DB_PASS", "flaskpass123")

def get_db_connection():
    return psycopg2.connect(host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASS)

@app.route("/", methods=["GET"])
def home():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, task FROM todos ORDER BY id DESC;")
    records = cur.fetchall()
    cur.close()
    conn.close()
    
    tasks_list = [{"id": r[0], "task": r[1]} for r in records]
    return render_template("index.html", tasks=tasks_list, architecture="1-Tier Monolith", db_host=DB_HOST)

@app.route("/add", methods=["POST"])
def add_task():
    task_text = request.form.get("task")
    if task_text:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("INSERT INTO todos (task) VALUES (%s);", (task_text,))
        conn.commit()
        cur.close()
        conn.close()
    return redirect(url_for("home"))

@app.route("/update/<int:task_id>", methods=["GET", "POST"])
def update_task(task_id):
    conn = get_db_connection()
    cur = conn.cursor()
    
    if request.method == "POST":
        new_task_text = request.form.get("task")
        if new_task_text:
            cur.execute("UPDATE todos SET task = %s WHERE id = %s;", (new_task_text, task_id))
            conn.commit()
        cur.close()
        conn.close()
        return redirect(url_for("home"))
    
    cur.execute("SELECT id, task FROM todos WHERE id = %s;", (task_id,))
    record = cur.fetchone()
    cur.close()
    conn.close()
    
    if not record:
        return redirect(url_for("home"))
        
    return render_template("edit.html", task={"id": record[0], "task": record[1]})

@app.route("/delete/<int:task_id>", methods=["POST"])
def delete_task(task_id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM todos WHERE id = %s;", (task_id,))
    conn.commit()
    cur.close()
    conn.close()
    return redirect(url_for("home"))

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)