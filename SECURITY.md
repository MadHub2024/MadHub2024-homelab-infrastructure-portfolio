# Publishing and Sanitization Checklist

Before pushing any update to a public repository, verify that it does not contain:

- Passwords or password hashes
- API keys, access tokens, or session cookies
- Private keys or Caddy CA material
- Tailscale authentication keys
- Cloudflare API tokens
- Public static IP allocation details
- Personal addresses or private client information
- Full internal configuration backups
- Unredacted email logs
- Vaultwarden database files

RFC1918 addresses such as `10.10.40.0/24` are not internet-routable, but use them only when they improve the technical explanation.

Recommended placeholders:

- `REDACTED_TOKEN`
- `example.internal`
- `10.10.40.10`
- `user@example.com`
