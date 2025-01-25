#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys
from dotenv import load_dotenv
from pathlib import Path

def main():
    """Run administrative tasks."""
    # Load environment variables from the .env file
    base_dir = Path(__file__).resolve().parent
    dotenv_path = base_dir / '.env'
    load_dotenv(dotenv_path)
    
    # Set the default settings module
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings.dev')  # Default to dev settings
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)

if __name__ == '__main__':
    main()
