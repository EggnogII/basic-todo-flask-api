from flask import Flask, render_template, request, jsonify
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
all_todos = database_manager.view_all_todos()
#database_manager.delete_all_todos()

@app.route('/')
def index():
	return render_template('index.html', todos=all_todos)

@app.route('/add', methods=['POST'])
def postRequest():
	title = request.form.get('title')
	description = request.form.get('description')
	deadline = request.form.get('deadline')
	status = request.form.get('status')
	todo = models.ToDo(id=0, title=title, description=description, deadline=deadline, status=status)
	print("New TODO: ", todo.serialize())
	database_manager.add_todo(todo)
	return jsonify({
		'res': todo.serialize(),
		'status': 200,
		'msg': 'Successfully added todo action'
	})

@app.route('/request', methods=['GET'])
def getRequest():
	content_type = request.headers.get('Content-Type')
	todos = [t.serialize() for t in database_manager.view_all_todos()]
	if (content_type == 'application/json'):
		json = request.json
		for t in todos:
			if (t['id'] == int(json['id'])):
				return jsonify({
					'res': t,
					'status': 200,
					'msg': 'Successfully got todo action'
				})
		return jsonify({
			'error': 'No todo found',
			'status': 404,
			'res': None
		})
	else:
		return jsonify({
			'res': todos,
			'status': 200,
			'msg': 'Successfully got all todo actions',
			'number_of_todos': len(todos)
		})

@app.route('/request', methods=['PUT'])
def putRequest():
	id = request.form.get('id')
	for todo in database_manager.view_all_todos():
		if (todo.id == int(id)):
			title = request.form.get('title')
			description = request.form.get('description')
			deadline = request.form.get('deadline')
			status = request.form.get('status')
			database_manager.update_todo(int(id), models.ToDo(id=int(id), title=title, description=description, deadline=deadline, status=status))
			return jsonify({
				'res': todo.serialize(),
				'status': 200,
				'msg': 'Successfully added todo action'
			})
	return jsonify({
		'error': 'No todo found',
		'status': 404,
		'res': None
	})

@app.route('/request/<id>', methods=['DELETE'])
def deleteRequest(id):
	for todo in database_manager.view_all_todos():
		if (todo.id == int(id)):
			database_manager.delete_todo(int(id))
			return jsonify({
				'res': todo.serialize(),
				'status': 200,
				'msg': 'Successfully deleted todo action'
			})
	return jsonify({
		'error': 'No todo found',
		'status': 404,
		'res': None
	})

@app.route('/health', methods=['GET'])
def health_check():
	return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
	app.run(host="0.0.0.0", port=80)
