import uuid
import psycopg2
import json
import random
from models import ToDo


"""
def get_new_id():
    id = uuid.uuid1()
    return id.int
"""

def get_id():
    id = random.getrandbits(28)
    return id

def read_manifest():
    with open('manifest.json') as json_file:
        return json.load(json_file)

class DatabaseManagement:
    def __init__(self):
        config = read_manifest()
        self.host = config['database_server_host']
        self.port = config['database_server_port']
        self.db = config['database']
        self.user = config['db_user']
        self.password = config['db_password']
        self.connection = None
        self.cursor = None

    def connect(self):
        self.connection = psycopg2.connect(
            host=self.host,
            port=self.port,
            dbname=self.db,
            user=self.user,
            password=self.password
        )

        self.cursor = self.connection.cursor()
        try:
            self.cursor.execute("CREATE TABLE IF NOT EXISTS todos (id SERIAL PRIMARY KEY, title TEXT, description TEXT, deadline TIMESTAMP, status TEXT)")
            self.connection.commit()
        except Exception as e:
            print(e)
            self.cursor.close()
            self.connection.close()
            return -1
        
   
    def add_todo(self, Todo):
        id = get_id()
        try:
            self.cursor.execute("INSERT INTO todos (id, title, description, deadline, status) VALUES (%s, %s, %s, %s, %s)", (id, Todo.title, Todo.description, Todo.deadline, Todo.status))
            self.connection.commit()
        except Exception as e:
            print(e)
            self.cursor.close()
            self.connection.close()
            return -1
    
    def view_all_todos(self):
        try:
            self.cursor.execute("SELECT * FROM todos")
            todos = self.cursor.fetchall()
            return [ToDo(id=t[0], title=t[1], description=t[2], deadline=t[3], status=t[4]) for t in todos]
        except Exception as e:
            print(e)
            self.cursor.close()
            self.connection.close()
            return []
    
    def update_todo(self, id, Todo):
        try:
            self.cursor.execute("UPDATE todos SET title = %s, description = %s, deadline = %s, status = %s WHERE id = %s", (Todo.title, Todo.description, Todo.deadline, Todo.status, id))
            self.connection.commit()
        except Exception as e:
            print(e)
            self.cursor.close()
            self.connection.close()
            return -1

    def delete_todo(self, id):
        try:
            self.cursor.execute("DELETE FROM todos WHERE id = %s", (id,))
            self.connection.commit()
        except Exception as e:
            print(e)
            self.cursor.close()
            self.connection.close()
            return -1
    
    def delete_all_todos(self):
        try:
            self.cursor.execute("DELETE FROM todos")
            self.connection.commit()
        except Exception as e:
            print(e)
            self.cursor.close()
            self.connection.close()
            return -1