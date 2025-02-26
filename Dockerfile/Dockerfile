FROM python:slim

WORKDIR /home/basic-todo-flask-api

COPY requirements.txt requirements.txt
RUN apt-get -y update; apt-get -y upgrade
RUN apt-get -y install build-essential libpq-dev curl
RUN python -m venv venv
RUN venv/bin/pip install -r requirements.txt
RUN venv/bin/pip install gunicorn

COPY . .

EXPOSE 80 5432
RUN chmod +x entrypoint.sh

HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -f http://localhost:80/health || exit 1
CMD ["./entrypoint.sh"]