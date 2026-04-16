import tkinter as tk
from tkinter import messagebox

# ---------- data storage ----------
tasks = []

# ---------- code functions ----------
def add_task():
    task = entry.get().strip()
    if task == "":
        messagebox.showwarning("Input Error", "Task cannot be empty")
        return
    tasks.append(task)
    entry.delete(0, tk.END)
    entry.focus_set()
    update_list()

def remove_task():
    selection = listbox.curselection()
    if not selection:
        return
    index = selection[0]
    del tasks[index]
    update_list()

def edit_task():
    selection = listbox.curselection()
    if not selection:
        return
    index = selection[0]
    new_task = entry.get().strip()
    if new_task == "":
        return
    tasks[index] = new_task
    entry.delete(0, tk.END)
    entry.focus_set()
    update_list()

def update_list():
    listbox.delete(0, tk.END)
    for task in tasks:
        listbox.insert(tk.END, task)

def load_selected(event):
    selection = listbox.curselection()
    if selection:
        index = selection[0]
        entry.delete(0, tk.END)
        entry.insert(0, tasks[index])

# ---------- move tasks ----------
def move_up():
    selection = listbox.curselection()
    if not selection or selection[0] == 0:
        return
    i = selection[0]
    tasks[i], tasks[i-1] = tasks[i-1], tasks[i]
    update_list()
    listbox.selection_set(i-1)

def move_down():
    selection = listbox.curselection()
    if not selection or selection[0] == len(tasks)-1:
        return
    i = selection[0]
    tasks[i], tasks[i+1] = tasks[i+1], tasks[i]
    update_list()
    listbox.selection_set(i+1)

# ---------- menu for right click ----------
def show_menu(event):
    try:
        index = listbox.nearest(event.y)
        listbox.selection_clear(0, tk.END)
        listbox.selection_set(index)
        listbox.activate(index)

        menu.tk_popup(event.x_root, event.y_root)
    finally:
        menu.grab_release()

# ---------- gui variables ----------
root = tk.Tk()
root.title("Manage ur tasks")
root.geometry("480x560")
root.configure(bg="#f5f5f5")
root.resizable(False, False)

main_frame = tk.Frame(root, bg="#f5f5f5")
main_frame.pack(expand=True, padx=20, pady=20)

title = tk.Label(main_frame, text="Manage ur tasks", font=("Arial", 16, "bold"), bg="#f5f5f5")
title.pack(pady=(0, 16))

entry = tk.Entry(main_frame, font=("Arial", 12))
entry.pack(pady=(0, 16), fill="x")

# Buttons
btn_frame = tk.Frame(main_frame, bg="#f5f5f5")
btn_frame.pack(pady=(0, 18))

tk.Button(btn_frame, text="Add", command=add_task, bg="#4CAF50", fg="white", width=12).grid(row=0, column=0, padx=6)
tk.Button(btn_frame, text="Edit", command=edit_task, bg="#2196F3", fg="white", width=12).grid(row=0, column=1, padx=6)
tk.Button(btn_frame, text="Delete", command=remove_task, bg="#f44336", fg="white", width=12).grid(row=0, column=2, padx=6)

# Frame to group list + move buttons
list_section = tk.Frame(main_frame, bg="#f5f5f5")
list_section.pack()

# Move buttons on the left side of the list
move_frame = tk.Frame(list_section, bg="#f5f5f5", width=120)
move_frame.grid(row=0, column=0, sticky="nw", padx=(0, 24), pady=(2, 0))
move_frame.grid_propagate(False)

tk.Button(
    move_frame,
    text="⬆ Move Up",
    command=move_up,
    font=("Arial", 10, "bold"),
    bg="#e0e0e0",
    width=12
).pack(pady=(0, 10))

tk.Button(
    move_frame,
    text="⬇ Move Down",
    command=move_down,
    font=("Arial", 10, "bold"),
    bg="#e0e0e0",
    width=12
).pack()

# Spacer to balance the left-side buttons and keep the list centered
spacer = tk.Frame(list_section, width=120, bg="#f5f5f5")
spacer.grid(row=0, column=2)

# Listbox
listbox = tk.Listbox(list_section, width=40, height=14, font=("Arial", 11))
listbox.grid(row=0, column=1, sticky="n")

list_section.grid_columnconfigure(1, minsize=360)

listbox.bind("<<ListboxSelect>>", load_selected)
listbox.bind("<Button-3>", show_menu)  # RIGHT CLICK FIXED

# Keyboard shortcuts
listbox.bind("<Delete>", lambda e: remove_task())

# Right-click menu
menu = tk.Menu(root, tearoff=0)
menu.add_command(label="Edit Task", command=edit_task)
menu.add_command(label="Delete Task", command=remove_task)

root.mainloop()
