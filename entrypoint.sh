#!/bin/bash
source venv/bin/activate
exec gunicorn -b 0.0.0.0:80 app:app