class ToDo:
    def __init__(self, id, title, description, deadline, status):
        self.id = id
        self.title = title
        self.description = description
        self.deadline = deadline
        self.status = status
    
    def __repr__(self):
        return '<id {}>'.format(self.id)

    def serialize(self):
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'deadline': self.deadline,
            'status': self.status
        }