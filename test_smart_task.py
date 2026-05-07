from importlib.machinery import SourceFileLoader

smart_task = SourceFileLoader(
    "smart_task",
    "Final Code/smart_task_manager.py"
).load_module()

TaskModel = smart_task.TaskModel
TaskController = smart_task.TaskController


def test_valid_date():
    controller = TaskController.__new__(TaskController)
    assert controller.validate_date("2026-05-07") == True


def test_invalid_date():
    controller = TaskController.__new__(TaskController)
    assert controller.validate_date("2026-02-31") == False


def test_add_task():
    model = TaskModel(":memory:")

    model.add_task(
        "Essay",
        "Math",
        "2026-06-01",
        "High",
        "Pending"
    )

    tasks = model.get_tasks()

    assert len(tasks) == 1
    assert tasks[0][1] == "Essay"


def test_delete_task():
    model = TaskModel(":memory:")

    model.add_task(
        "Delete Me",
        "Physics",
        "2026-06-10",
        "Low",
        "Pending"
    )

    task_id = model.get_tasks()[0][0]

    model.delete_task(task_id)

    tasks = model.get_tasks()

    assert len(tasks) == 0


print("All tests passed.")
