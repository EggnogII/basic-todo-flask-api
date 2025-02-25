FROM python:slim

WORKDIR /home/basic-todo-flask-api

COPY requirements.txt requirements.txt
RUN apt-get -y install libpq-dev
RUN python -m venv venv
RUN venv/bin/pip install -r requirements.txt
RUN venv/bin/pip install gunicorn

COPY . .

RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]