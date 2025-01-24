#!/bin/bash

source /home/administrator/devops-assessment/Task1-VersionControl/env/bin/activate
exec gunicorn -b 127.0.0.1:8000 -w 3 --chdir /home/administrator/devops-assessment/Task1-VersionControl/app/backend backend.wsgi:application


