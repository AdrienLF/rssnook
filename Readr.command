#!/usr/bin/env bash
# Double-click this file in Finder to launch Readr.
set -euo pipefail

cd "$(dirname "$0")"

MODEL="qwen3.5:9b"
URL="http://localhost:7755"

say() { printf '\n\033[1;36m[readr]\033[0m %s\n' "$*"; }
die() { printf '\n\033[1;31m[readr]\033[0m %s\n\n' "$*" >&2; read -r -p "Press Return to close." _; exit 1; }

# ── Docker daemon ──────────────────────────────────────────────────────────────
command -v docker &>/dev/null || die "Docker isn't installed. Get Docker Desktop: https://docker.com/products/docker-desktop"

if ! docker info &>/dev/null; then
  say "Starting Docker Desktop…"
  open -a Docker || die "Couldn't launch Docker Desktop."
  for _ in $(seq 60); do
    docker info &>/dev/null && break
    sleep 2
  done
  docker info &>/dev/null || die "Docker didn't come up within two minutes."
fi

# ── Containers ─────────────────────────────────────────────────────────────────
say "Starting containers…"
docker compose up -d --build \
  || die "Containers failed to start. If this says 'no space left on device', Docker's disk is full: raise the limit in Docker Desktop → Settings → Resources, or reclaim space with 'docker system prune -a'."

# ── Ollama model (first run pulls ~5GB) ────────────────────────────────────────
if ! docker compose exec -T ollama ollama list 2>/dev/null | grep -qF "$MODEL"; then
  say "Pulling the $MODEL model — first run only, this takes a while."
  docker compose exec -T ollama ollama pull "$MODEL" || say "Model pull failed; the digest won't work until it succeeds. Everything else will."
fi

# ── Wait for the app, then open it ─────────────────────────────────────────────
say "Waiting for Readr to answer…"
for _ in $(seq 60); do
  if curl -fsS -o /dev/null --max-time 2 "$URL"; then
    say "Ready. Opening $URL"
    open "$URL"
    say "Readr runs in the background. Stop it with: docker compose down"
    sleep 3
    exit 0
  fi
  sleep 2
done

die "Readr didn't respond at $URL. Check the logs with: docker compose logs"
