from models import Task
from database import save_task, load_tasks

class TaskManager:
    def __init__(self):
        self.tasks = load_tasks()

    def add_task(self, name, deadline, priority):
        task = Task(name, deadline, priority)
        self.tasks.append(task)
        save_task(task)
        return task

    def delete_task(self, index):
        if 0 <= index < len(self.tasks):
            return self.tasks.pop(index)

    def get_tasks(self):
        return self.tasks

    def mark_task_complete(self, index):
        if 0 <= index < len(self.tasks):
            self.tasks[index].mark_completed()
