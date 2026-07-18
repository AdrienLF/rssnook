#!/usr/bin/env bash
set -e

# Stop containers created by releases before the project rename. Bind-mounted
# application data is left in place and migrated by the new backend entrypoint.
legacy_project="readr"
if docker ps -aq --filter "label=com.docker.compose.project=$legacy_project" | grep -q .; then
  echo "[rssnook] Stopping containers from the previous project name"
  docker compose -p "$legacy_project" down --remove-orphans
fi

# ── NVIDIA GPU ─────────────────────────────────────────────────────────────────
if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null 2>&1; then
  echo "[rssnook] NVIDIA GPU detected — starting with GPU support"
  docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d "$@"

# ── CPU (macOS, no-GPU Linux) ──────────────────────────────────────────────────
else
  echo "[rssnook] Starting (CPU inference)"
  docker compose up -d "$@"
fi
