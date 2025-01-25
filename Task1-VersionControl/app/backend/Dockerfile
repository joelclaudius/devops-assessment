# Backend Dockerfile
FROM python:3.11-slim

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y build-essential bash

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install Gunicorn
RUN pip install gunicorn

# Copy application code
COPY . .

# Expose the port used by Gunicorn
EXPOSE 8000

# Start Gunicorn server using bash
CMD ["bash", "gunicorn_start.sh"]
