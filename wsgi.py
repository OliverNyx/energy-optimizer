"""
wsgi.py — Gunicorn entry point.

Usage:
    gunicorn --config gunicorn.conf.py wsgi:application
"""
import os
from pathlib import Path

# Load .env if python-dotenv is installed and .env exists
try:
    from dotenv import load_dotenv
    _env = Path(__file__).resolve().parent / ".env"
    if _env.exists():
        load_dotenv(_env)
except ImportError:
    pass

from app.app import create_app

application = create_app()

if __name__ == "__main__":
    application.run(
        host="0.0.0.0",
        port=int(os.getenv("FLASK_PORT", "5000")),
        debug=os.getenv("FLASK_DEBUG", "false").lower() == "true",
    )
