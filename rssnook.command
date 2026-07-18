#!/usr/bin/env bash
# Double-click this file in Finder to launch rssnook.
set -euo pipefail

cd "$(dirname "$0")"

URL="http://localhost:7755"
FALLBACK_MODEL="qwen3.5:9b"   # used only if the app can't tell us which model it wants

say() { printf '\n\033[1;36m[rssnook]\033[0m %s\n' "$*"; }
die() { printf '\n\033[1;31m[rssnook]\033[0m %s\n\n' "$*" >&2; read -r -p "Press Return to close." _; exit 1; }

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
bash start.sh --build \
  || die "Containers failed to start. If this says 'no space left on device', Docker's disk is full: raise the limit in Docker Desktop → Settings → Resources, or reclaim space with 'docker system prune -a'."

# ── Wait for the app ───────────────────────────────────────────────────────────
# Poll the API, not just the frontend: nginx serves the UI before the backend is
# up, so a 200 on / says nothing about whether the app actually works yet.
say "Waiting for rssnook to answer…"
ready=""
for _ in $(seq 60); do
  if curl -fsS -o /dev/null --max-time 2 "$URL/api/settings"; then ready=1; break; fi
  sleep 2
done
[ -n "$ready" ] || die "rssnook didn't respond at $URL. Check the logs with: docker compose logs"

# ── Ollama model (first run pulls several GB) ──────────────────────────────────
# Ask the app which model it's configured for, so the pull can't drift from the
# ollama_model setting.
model=$(curl -fsS --max-time 5 "$URL/api/settings" 2>/dev/null \
  | sed -n 's/.*"ollama_model" *: *"\([^"]*\)".*/\1/p') || true
model="${model:-$FALLBACK_MODEL}"

if ! docker compose exec -T ollama ollama list 2>/dev/null | grep -qF "$model"; then
  say "Pulling the $model model — first run only, this takes a while."
  docker compose exec -T ollama ollama pull "$model" \
    || say "Model pull failed; digests won't work until it succeeds. Everything else will."
fi

# ── Open it ────────────────────────────────────────────────────────────────────
say "Ready. Opening $URL"
open "$URL"
say "rssnook runs in the background. Stop it with: docker compose down"
sleep 3
