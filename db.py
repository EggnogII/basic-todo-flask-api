import uuid
import psycopg2
import json

def get_new_id():
    id = uuid.uuid1()
    return id.int

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
        self.cursor.execute("CREATE TABLE IF NOT EXISTS todos (id SERIAL PRIMARY KEY, title TEXT, description TEXT, deadline TIMESTAMP, status TEXT)")
        self.connection.commit()
   