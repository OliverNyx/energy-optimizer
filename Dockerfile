# ─────────────────────────────────────────────────────────────
# Stage 1: build dependencies in a clean layer
# ─────────────────────────────────────────────────────────────
FROM python:3.11-slim AS builder

WORKDIR /build

# System packages needed to compile XGBoost / LightGBM / scipy wheels
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        libgomp1 \
        libffi-dev \
        libssl-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# ─────────────────────────────────────────────────────────────
# Stage 2: lean runtime image
# ─────────────────────────────────────────────────────────────
FROM python:3.11-slim AS runtime

# libgomp1 is required at runtime by LightGBM / XGBoost
RUN apt-get update && apt-get install -y --no-install-recommends \
        libgomp1 \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Copy compiled packages from builder
COPY --from=builder /install /usr/local

WORKDIR /app

# ── Application source ────────────────────────────────────────
COPY app/           ./app/
COPY wsgi.py        .
COPY gunicorn.conf.py .
COPY entrypoint.sh  .
COPY data/ ./data/
COPY models/ ./models/
COPY static/ ./static/

# ── Runtime directories (may be bind-mounted as volumes) ──────
RUN mkdir -p /app/data /app/models /app/logs /app/static

# ── Non-root user for security ────────────────────────────────
RUN useradd --no-create-home --uid 1000 appuser \
    && chown -R appuser:appuser /app

USER appuser

EXPOSE 5000

# entrypoint.sh: verify/train models, then launch Gunicorn
ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]
