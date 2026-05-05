from services import TaskManager
from database import init_db

def run_app():
    init_db()
    manager = TaskManager()

    # tempory, testing
    print("App running...")
    print("Current tasks:", manager.get_tasks())
