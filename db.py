import uuid

def get_new_id():
    id = uuid.uuid1()
    return id.int

