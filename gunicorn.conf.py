"""
gunicorn.conf.py — Production Gunicorn configuration.
Read automatically when passed via:  gunicorn --config gunicorn.conf.py ...
"""
import os
from pathlib import Path

# ── Binding ───────────────────────────────────────────────────
bind    = os.getenv("GUNICORN_BIND",    "0.0.0.0:5000")
backlog = 2048

# ── Workers ───────────────────────────────────────────────────
# NOTE: STATE is in-memory. With >1 worker each process has its own
# STATE — acceptable for a demo/university deployment.
# For a fully stateful multi-worker setup, move STATE to Redis.
workers          = int(os.getenv("GUNICORN_WORKERS", "1"))
worker_class     = "sync"
worker_connections = 1000
threads          = 1

# ── Timeouts ──────────────────────────────────────────────────
# LP optimisation + model inference can take several seconds.
timeout          = int(os.getenv("GUNICORN_TIMEOUT", "120"))
graceful_timeout = 30
keepalive        = 5

# ── Request limits ────────────────────────────────────────────
max_requests        = 1000
max_requests_jitter = 100

# ── Preload (load app once, fork workers) ─────────────────────
# Saves memory; safe because STATE is process-local.
preload_app = True

# ── Logging ───────────────────────────────────────────────────
_log_dir = Path(os.getenv("LOG_DIR", "/app/logs"))
_log_dir.mkdir(parents=True, exist_ok=True)

accesslog  = str(_log_dir / "gunicorn_access.log")
errorlog   = str(_log_dir / "gunicorn_error.log")
loglevel   = os.getenv("LOG_LEVEL", "info").lower()
access_log_format = (
    '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s '
    '"%(f)s" "%(a)s" %(D)sµs'
)

# ── Process name ──────────────────────────────────────────────
proc_name = "energy-optimizer"
