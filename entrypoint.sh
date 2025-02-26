#!/bin/bash
source venv/bin/activate
exec gunicorn -b 0.0.0.0:80 --workers=2 --worker-class=gevent app:app
#python3 app.py