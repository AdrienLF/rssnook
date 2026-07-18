# Contributing to rssnook

Thanks for helping improve rssnook. Bug reports, focused feature proposals, documentation fixes, and pull requests are welcome.

## Before you start

- Search existing issues before opening a new one.
- Use a GitHub Security Advisory instead of a public issue for vulnerabilities; see [SECURITY.md](SECURITY.md).
- For large behavior or data-model changes, open an issue first so the design can be discussed before implementation.

## Development setup

Clone the repository, then install each application's locked dependencies.

```bash
cd backend
uv sync --frozen

cd ../frontend
npm ci
```

Run the full stack with `docker compose up -d --build`. The application is served at `http://localhost:7755`.

## Required checks

Run these before submitting a pull request:

```bash
cd backend
uv run pytest

cd ../frontend
npm test
npm run build
```

Changes to browser behavior should also be exercised against a running Compose stack with `BASE_URL=http://localhost:7755 npm run test:e2e` from `frontend/`.

## Pull requests

- Keep each pull request focused on one coherent change.
- Add or update tests for observable behavior.
- Update the README, in-app docs, or architecture document when behavior or setup changes.
- Do not commit local databases, environment files, build output, or model data.
- Describe user-visible effects and any migration or rollback considerations in the pull request body.

By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).
