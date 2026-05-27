#!/bin/sh
# entrypoint.sh
# 1. Create required runtime directories
# 2. Verify model artefacts; run training pipeline if absent
# 3. Launch Gunicorn
set -e

echo "============================================================"
echo "  Smart Energy Optimizer — startup"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"

# ── 1. Directories ────────────────────────────────────────────
echo "[1/3] Ensuring runtime directories exist …"
mkdir -p "${DATA_DIR:-/app/data}"
mkdir -p "${MODELS_DIR:-/app/models}"
mkdir -p "${LOG_DIR:-/app/logs}"
mkdir -p "${STATIC_DIR:-/app/static}"
echo "      OK"

# ── 2. Model artefacts ────────────────────────────────────────
echo "[2/3] Checking model artefacts …"
SIM_FRAME="${MODELS_DIR:-/app/models}/sim_frame.pkl"

if [ ! -f "$SIM_FRAME" ]; then
    echo ""
    echo "  ⚠  Artefacts not found at ${MODELS_DIR:-/app/models}"
    echo "  ▶  Running training pipeline — this may take several minutes …"
    echo ""
    python -m app.train_models
    echo ""
    echo "  ✅ Training complete"
else
    echo "      Artefacts found — skipping training"
fi

# ── 3. Launch Gunicorn ────────────────────────────────────────
echo "[3/3] Starting Gunicorn …"
echo ""
exec gunicorn \
    --config gunicorn.conf.py \
    wsgi:application
