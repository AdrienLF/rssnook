# Security policy

## Supported versions

Security fixes are applied to the latest release and the default branch. Older snapshots may not receive patches.

## Reporting a vulnerability

Please do not open a public issue for a suspected vulnerability. Use the repository's [private security advisory form](https://github.com/AdrienLF/rssnook/security/advisories/new) and include:

- the affected version or commit;
- a clear reproduction or proof of concept;
- the expected security impact;
- any mitigation you have already identified.

You should receive an acknowledgement within seven days. Please allow time for a fix and coordinated disclosure before publishing details.

## Deployment boundary

rssnook is intentionally a single-user application and does not provide authentication or authorization. Every client that can reach the application can read and change its data.

- Bind it to localhost or place it on a trusted private network such as Tailscale.
- Do not expose port 7755 directly to the public internet.
- If you place rssnook behind another reverse proxy, provide TLS and authentication there.
- Do not publish the backend, Ollama, or RSSHub service ports.
- Protect backups of `data/`; they contain feeds, articles, notes, and reading history.
- Keep Docker, the host operating system, and dependency updates current.

The absence of built-in multi-user authentication is a documented design constraint, not a vulnerability. Authentication bypasses in a deployment that adds an external access-control layer may still be security issues in that layer or its configuration.
