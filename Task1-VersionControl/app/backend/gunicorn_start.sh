#!/bin/bash

# Activate virtual environment using bash
source venv/bin/activate

# Start Gunicorn server
exec gunicorn -b 0.0.0.0:8000 -w 3 backend.wsgi:application
