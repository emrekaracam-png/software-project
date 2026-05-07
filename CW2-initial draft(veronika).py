import customtkinter as ctk
import tkinter as tk
from tkinter import ttk, messagebox
import sqlite3
from datetime import datetime


class TaskModel:

    def __init__(self, db_name="tasks.db"):
        self.conn = sqlite3.connect(db_name)
        self.create_table()

    def create_table(self):

        cursor = self.conn.cursor()

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                task_name TEXT,
                subject TEXT,
                deadline TEXT,
                priority TEXT,
                status TEXT
            )
        """)

        self.conn.commit()

    def add_task(self, name, subject, deadline, priority, status):

        cursor = self.conn.cursor()

        cursor.execute("""
            INSERT INTO tasks
            (task_name, subject, deadline, priority, status)
            VALUES (?, ?, ?, ?, ?)
        """, (name, subject, deadline, priority, status))

        self.conn.commit()

    def get_tasks(self):

        cursor = self.conn.cursor()

        cursor.execute("SELECT * FROM tasks")

        return cursor.fetchall()

    def update_task(self, task_id, name, subject, deadline, priority, status):

        cursor = self.conn.cursor()

        cursor.execute("""
            UPDATE tasks
            SET task_name=?,
                subject=?,
                deadline=?,
                priority=?,
                status=?
            WHERE id=?
        """, (name, subject, deadline, priority, status, task_id))

        self.conn.commit()

    def delete_task(self, task_id):

        cursor = self.conn.cursor()

        cursor.execute("DELETE FROM tasks WHERE id=?", (task_id,))

        self.conn.commit()


class TaskApp(ctk.CTk):

    def __init__(self):
        super().__init__()

        self.title("Task Manager")
        self.geometry("1000x600")

        ctk.set_appearance_mode("dark")

        self.model = TaskModel()

        self.selected_task_id = None

        self.create_widgets()
        self.load_tasks()

    def create_widgets(self):

        self.left_frame = ctk.CTkFrame(self, width=250)
        self.left_frame.pack(side="left", fill="y", padx=10, pady=10)

        self.right_frame = ctk.CTkFrame(self)
        self.right_frame.pack(side="right", fill="both", expand=True, padx=10, pady=10)

        title = ctk.CTkLabel(
            self.left_frame,
            text="Task Manager",
            font=("Arial", 20, "bold")
        )
        title.pack(pady=20)

        self.name_entry = ctk.CTkEntry(
            self.left_frame,
            placeholder_text="Task Name",
            width=200
        )
        self.name_entry.pack(pady=10)

        self.subject_entry = ctk.CTkEntry(
            self.left_frame,
            placeholder_text="Subject",
            width=200
        )
        self.subject_entry.pack(pady=10)

        self.deadline_entry = ctk.CTkEntry(
            self.left_frame,
            placeholder_text="YYYY-MM-DD",
            width=200
        )
        self.deadline_entry.pack(pady=10)

        self.priority_box = ctk.CTkComboBox(
            self.left_frame,
            values=["Low", "Medium", "High"],
            width=200
        )
        self.priority_box.pack(pady=10)
        self.priority_box.set("Medium")

        self.status_box = ctk.CTkComboBox(
            self.left_frame,
            values=["Pending", "Completed"],
            width=200
        )
        self.status_box.pack(pady=10)
        self.status_box.set("Pending")

        add_button = ctk.CTkButton(
            self.left_frame,
            text="Add Task",
            command=self.add_task
        )
        add_button.pack(pady=10)

        update_button = ctk.CTkButton(
            self.left_frame,
            text="Update Task",
            command=self.update_task
        )
        update_button.pack(pady=10)

        delete_button = ctk.CTkButton(
            self.left_frame,
            text="Delete Task",
            command=self.delete_task
        )
        delete_button.pack(pady=10)

        columns = (
            "ID",
            "Task",
            "Subject",
            "Deadline",
            "Priority",
            "Status"
        )

        self.tree = ttk.Treeview(
            self.right_frame,
            columns=columns,
            show="headings"
        )

        for col in columns:
            self.tree.heading(col, text=col)

        self.tree.column("ID", width=50)
        self.tree.column("Task", width=200)
        self.tree.column("Subject", width=150)
        self.tree.column("Deadline", width=120)
        self.tree.column("Priority", width=100)
        self.tree.column("Status", width=100)

        self.tree.pack(fill="both", expand=True)

        self.tree.bind("<<TreeviewSelect>>", self.select_task)

    def load_tasks(self):

        for row in self.tree.get_children():
            self.tree.delete(row)

        tasks = self.model.get_tasks()

        for task in tasks:
            self.tree.insert("", "end", values=task)

    def clear_fields(self):

        self.name_entry.delete(0, tk.END)
        self.subject_entry.delete(0, tk.END)
        self.deadline_entry.delete(0, tk.END)

        self.priority_box.set("Medium")
        self.status_box.set("Pending")

    def add_task(self):

        name = self.name_entry.get()
        subject = self.subject_entry.get()
        deadline = self.deadline_entry.get()
        priority = self.priority_box.get()
        status = self.status_box.get()

        if name == "":
            messagebox.showerror("Error", "Enter task name")
            return

        try:
            datetime.strptime(deadline, "%Y-%m-%d")
        except:
            messagebox.showerror("Error", "Use YYYY-MM-DD")
            return

        self.model.add_task(
            name,
            subject,
            deadline,
            priority,
            status
        )

        self.load_tasks()
        self.clear_fields()

    def update_task(self):

        if self.selected_task_id is None:
            return

        self.model.update_task(
            self.selected_task_id,
            self.name_entry.get(),
            self.subject_entry.get(),
            self.deadline_entry.get(),
            self.priority_box.get(),
            self.status_box.get()
        )

        self.load_tasks()
        self.clear_fields()

    def delete_task(self):

        if self.selected_task_id is None:
            return

        self.model.delete_task(self.selected_task_id)

        self.load_tasks()
        self.clear_fields()

    def select_task(self, event):

        selected = self.tree.focus()

        if not selected:
            return

        values = self.tree.item(selected, "values")

        self.selected_task_id = values[0]

        self.clear_fields()

        self.name_entry.insert(0, values[1])
        self.subject_entry.insert(0, values[2])
        self.deadline_entry.insert(0, values[3])

        self.priority_box.set(values[4])
        self.status_box.set(values[5])


if __name__ == "__main__":

    app = TaskApp()
    app.mainloop()