FROM python:3.12-slim

COPY --from=ghcr.io/astral-sh/uv:0.8.0 /uv /uvx /bin/

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libxml2-dev libxslt-dev gosu \
    && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

COPY app/ ./app/
COPY --chmod=755 entrypoint.sh /usr/local/bin/rssnook-entrypoint

RUN mkdir -p /app/data && \
    adduser --disabled-password --gecos "" --uid 1000 appuser && \
    chown -R appuser:appuser /app

EXPOSE 8000
ENTRYPOINT ["rssnook-entrypoint"]
CMD ["/app/.venv/bin/uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
