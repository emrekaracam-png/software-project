import sqlite3
from models import Task

DB_NAME = "tasks.db"

def get_connection():
    return sqlite3.connect(DB_NAME)

def init_db():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY,
            name TEXT,
            deadline TEXT,
            priority TEXT,
            completed INTEGER
        )
    """)
    conn.commit()
    conn.close()

def save_task(task):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO tasks (name, deadline, priority, completed)
        VALUES (?, ?, ?, ?)
    """, (task.name, task.deadline, task.priority, int(task.completed)))
    conn.commit()
    conn.close()

def load_tasks():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT name, deadline, priority, completed FROM tasks")
    rows = cursor.fetchall()
    conn.close()

    return [Task(name, deadline, priority) for name, deadline, priority, completed in rows]