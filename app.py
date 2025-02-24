from flask import Flask
import models
import db
from datetime import datetime

app = Flask(__name__)

database_manager = db.DatabaseManagement()
database_manager.connect()
# Basic Todo Object
todo_test_object = models.ToDo(id=0, title='test', description='test', deadline=datetime.now(), status='Done')

database_manager.add_todo(todo_test_object)
@app.route('/')
def hello_world():
	return 'Hello World!'

if __name__ == '__main__':
	app.run()
