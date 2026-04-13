import tkinter as tk
from tkinter import ttk, messagebox
import sqlite3
from datetime import datetime

# =========================
# MODEL
# =========================
class TaskModel:
    def __init__(self):
        self.conn = sqlite3.connect("tasks.db")
        self.create_table()

    def create_table(self):
        cursor = self.conn.cursor()
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            subject TEXT,
            deadline TEXT,
            priority TEXT,
            status TEXT
        )
        """)
        self.conn.commit()

    def add_task(self, task):
        cursor = self.conn.cursor()
        cursor.execute("""
        INSERT INTO tasks (name, subject, deadline, priority, status)
        VALUES (?, ?, ?, ?, ?)
        """, task)
        self.conn.commit()

    def get_tasks(self):
        cursor = self.conn.cursor()
        cursor.execute("SELECT * FROM tasks ORDER BY deadline")
        return cursor.fetchall()

    def delete_task(self, task_id):
        cursor = self.conn.cursor()
        cursor.execute("DELETE FROM tasks WHERE id=?", (task_id,))
        self.conn.commit()

    def update_task(self, task_id, task):
        cursor = self.conn.cursor()
        cursor.execute("""
        UPDATE tasks SET name=?, subject=?, deadline=?, priority=?, status=?
        WHERE id=?
        """, (*task, task_id))
        self.conn.commit()


# =========================
# VIEW
# =========================
class TaskView(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Smart Task Manager")
        self.geometry("850x600")

        self.build_ui()

    def build_ui(self):
        dash = ttk.LabelFrame(self, text="Dashboard")
        dash.pack(fill="x", padx=10, pady=10)

        self.lbl_total = ttk.Label(dash, text="Total: 0")
        self.lbl_total.pack(side="left", padx=20)

        self.lbl_completed = ttk.Label(dash, text="Completed: 0")
        self.lbl_completed.pack(side="left", padx=20)

        self.lbl_deadline = ttk.Label(dash, text="Next Deadline: None")
        self.lbl_deadline.pack(side="left", padx=20)

        form = ttk.LabelFrame(self, text="Add / Edit Task")
        form.pack(fill="x", padx=10, pady=10)

        self.ent_name = ttk.Entry(form)
        self.ent_name.grid(row=1, column=0, padx=5)

        self.ent_subject = ttk.Entry(form)
        self.ent_subject.grid(row=1, column=1, padx=5)

        self.ent_deadline = ttk.Entry(form)
        self.ent_deadline.grid(row=1, column=2, padx=5)

        self.cbo_priority = ttk.Combobox(form, values=["Low", "Medium", "High"])
        self.cbo_priority.set("Medium")
        self.cbo_priority.grid(row=1, column=3)

        self.cbo_status = ttk.Combobox(form, values=["Pending", "Completed"])
        self.cbo_status.set("Pending")
        self.cbo_status.grid(row=1, column=4)

        labels = ["Name", "Subject", "Deadline", "Priority", "Status"]
        for i, txt in enumerate(labels):
            ttk.Label(form, text=txt).grid(row=0, column=i)

        btns = ttk.Frame(self)
        btns.pack(pady=10)

        self.btn_add = ttk.Button(btns, text="Add Task")
        self.btn_add.grid(row=0, column=0, padx=5)

        self.btn_update = ttk.Button(btns, text="Update")
        self.btn_update.grid(row=0, column=1, padx=5)

        self.btn_delete = ttk.Button(btns, text="Delete")
        self.btn_delete.grid(row=0, column=2, padx=5)

        filter_frame = ttk.Frame(self)
        filter_frame.pack()

        self.filter_status = ttk.Combobox(filter_frame, values=["All", "Pending", "Completed"])
        self.filter_status.set("All")
        self.filter_status.pack(side="left", padx=5)

        self.filter_priority = ttk.Combobox(filter_frame, values=["All", "Low", "Medium", "High"])
        self.filter_priority.set("All")
        self.filter_priority.pack(side="left", padx=5)

        cols = ("ID", "Name", "Subject", "Deadline", "Priority", "Status")
        self.tree = ttk.Treeview(self, columns=cols, show="headings")

        for c in cols:
            self.tree.heading(c, text=c)
            self.tree.column(c, width=120)

        self.tree.column("ID", width=0)
        self.tree.pack(fill="both", expand=True, padx=10, pady=10)

        # COLOURS
        self.tree.tag_configure("urgent", foreground="red")
        self.tree.tag_configure("warning", foreground="orange")
        self.tree.tag_configure("done", foreground="green")  # changed to green


# =========================
# CONTROLLER
# =========================
class TaskController:
    def __init__(self, model, view):
        self.model = model
        self.view = view

        view.btn_add.config(command=self.add_task)
        view.btn_delete.config(command=self.delete_task)
        view.btn_update.config(command=self.update_task)

        self.refresh()

    def add_task(self):
        name = self.view.ent_name.get()
        subject = self.view.ent_subject.get()
        deadline = self.view.ent_deadline.get()

        if not name or not deadline:
            messagebox.showerror("Error", "Name + deadline required")
            return

        task = (
            name,
            subject,
            deadline,
            self.view.cbo_priority.get(),
            self.view.cbo_status.get()
        )

        self.model.add_task(task)
        self.refresh()

    def delete_task(self):
        selected = self.view.tree.selection()
        if not selected:
            return

        task_id = self.view.tree.item(selected[0])['values'][0]
        self.model.delete_task(task_id)
        self.refresh()

    def update_task(self):
        selected = self.view.tree.selection()
        if not selected:
            return

        task_id = self.view.tree.item(selected[0])['values'][0]

        task = (
            self.view.ent_name.get(),
            self.view.ent_subject.get(),
            self.view.ent_deadline.get(),
            self.view.cbo_priority.get(),
            self.view.cbo_status.get()
        )

        self.model.update_task(task_id, task)
        self.refresh()

    def refresh(self):
        for row in self.view.tree.get_children():
            self.view.tree.delete(row)

        tasks = self.model.get_tasks()

        total = len(tasks)
        completed = 0
        deadlines = []

        today = datetime.now()

        for t in tasks:
            tag = ""

            if t[5] == "Completed":
                tag = "done"
                completed += 1
            else:
                date = datetime.strptime(t[3], "%Y-%m-%d")
                deadlines.append(date)
                days_left = (date - today).days

                if days_left <= 2:
                    tag = "urgent"
                elif days_left <= 5:
                    tag = "warning"

            self.view.tree.insert("", tk.END, values=t, tags=(tag,) if tag else ())

        self.view.lbl_total.config(text=f"Total: {total}")
        self.view.lbl_completed.config(text=f"Completed: {completed}")

        if deadlines:
            next_d = min(deadlines)
            self.view.lbl_deadline.config(text=f"Next Deadline: {next_d.strftime('%Y-%m-%d')}")

            if (next_d - today).days <= 2:
                self.view.lbl_deadline.config(foreground="red")
            elif (next_d - today).days <= 5:
                self.view.lbl_deadline.config(foreground="orange")
            else:
                self.view.lbl_deadline.config(foreground="black")


# =========================
# RUN
# =========================
if __name__ == "__main__":
    model = TaskModel()
    view = TaskView()
    controller = TaskController(model, view)
    view.mainloop()