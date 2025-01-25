from .base import *

# Production-specific settings
DEBUG = True
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', '').split(',')

# Database settings for production (PostgreSQL)
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('DB_NAME', 'postgres'),
        'USER': os.getenv('DB_USER', 'postgres'),
        'PASSWORD': os.getenv('DB_PASSWORD', 'examplepassword'),
        'HOST': os.getenv('DB_HOST', 'database'),
        'PORT': os.getenv('DB_PORT', '5432'),
    }
}

# Security settings
SECURE_SSL_REDIRECT = False
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True
