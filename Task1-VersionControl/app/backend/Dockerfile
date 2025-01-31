FROM python:3.11-slim

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    bash \
    libpq-dev \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /app/venv

# Ensure pip is up-to-date
RUN /app/venv/bin/pip install --no-cache-dir --upgrade pip

# Copy only requirements file first to leverage Docker layer caching
COPY requirements.txt .

# Install Python dependencies
RUN /app/venv/bin/pip install --no-cache-dir -r requirements.txt \
    && /app/venv/bin/pip install gunicorn

# Copy application code
COPY . .

# Ensure Gunicorn script is executable
RUN chmod +x gunicorn_start.sh

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PATH="/app/venv/bin:$PATH"
ENV DJANGO_SETTINGS_MODULE=backend.settings.prod

# Expose the port used by Gunicorn
EXPOSE 8000

# Wait for the database to be available, run migrations, and start Gunicorn
CMD ["bash", "-c", "while ! nc -z ${DB_HOST} 5432; do sleep 1; done; /app/venv/bin/python manage.py migrate; /app/venv/bin/gunicorn backend.wsgi:application --bind 0.0.0.0:8000"]
