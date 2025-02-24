from flask import Flask
import db

app = Flask(__name__)

database_manager = db.DatabaseManagement()
database_manager.connect()

@app.route('/')
def hello_world():
	return 'Hello World!'

if __name__ == '__main__':
	app.run()
