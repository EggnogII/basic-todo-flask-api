from flask import Flask
import models
import db
from datetime import datetime

app = Flask(__name__)

database_manager = db.DatabaseManagement()
database_manager.connect()

## Testing, please ignore
# Basic Todo Object
#todo_test_object = models.ToDo(id=0, title='testing', description='testing', deadline=datetime.now(), status='Done')
# Test Add Todo
#database_manager.add_todo(todo_test_object)
#database_manager.delete_todo(33622889)
#database_manager.update_todo(230471354, todo_test_object)
#all_todos = database_manager.view_all_todos()
#database_manager.delete_all_todos()

@app.route('/')
def hello_world():
	return 'Hello World!'

if __name__ == '__main__':
	app.run()
