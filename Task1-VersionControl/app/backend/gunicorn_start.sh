#!/bin/bash

# Activate virtual environment
source /app/venv/bin/activate

# Run migrations
/app/venv/bin/python /app/manage.py migrate

# Start Gunicorn server
exec gunicorn -b 0.0.0.0:8000 -w 3 backend.wsgi:application
