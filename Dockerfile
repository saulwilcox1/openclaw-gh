FROM ghcr.io/openclaw/openclaw:2026.9.6

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl gnupg ca-certificates \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg \
  | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null \
 && curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.tailscale-keyring.list \
  | tee /etc/apt/sources.list.d/tailscale.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends tailscale \
 && rm -rf /var/lib/apt/lists/*

 # Override `tailscale` in PATH with a wrapper that uses the real Tailscale container.
 RUN cat > /usr/local/bin/tailscale <<'EOF'
#!/bin/sh
set -eu
exec docker exec ix-tailscale-tailscale-1 tailscale "$@"
EOF
RUN chmod +x /usr/local/bin/tailscale

USER 568:568
