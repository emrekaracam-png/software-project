class Task:
    def __init__(self, name, deadline, priority):
        self.name = name
        self.deadline = deadline
        self.priority = priority
        self.completed = False

    def mark_completed(self):
        self.completed = True

    def __repr__(self):
        return f"Task({self.name}, {self.deadline}, {self.priority}, {self.completed})"