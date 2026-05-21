# syntax=docker/dockerfile:1.7

# Minimal multi-arch image for mager-agent.
# Bundles cloudflared from Cloudflare's official image (multi-arch) so the
# agent has no runtime dependency on the host's package manager.

# --- Stage 1: build the agent (cross-compile for the target arch) ------------
FROM --platform=$BUILDPLATFORM golang:1.22-alpine AS builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /src
COPY go.mod ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -trimpath -ldflags="-s -w" -o /out/mager-agent ./cmd/mager-agent

# --- Stage 2: pull cloudflared from Cloudflare's official image --------------
FROM cloudflare/cloudflared:latest AS cf

# --- Stage 3: runtime --------------------------------------------------------
FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata \
    && addgroup -S mager \
    && adduser -S -G mager -H -h /var/lib/mager mager \
    && mkdir -p /var/lib/mager \
    && chown mager:mager /var/lib/mager

COPY --from=builder /out/mager-agent /usr/local/bin/mager-agent
COPY --from=cf /usr/local/bin/cloudflared /usr/local/bin/cloudflared
COPY entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh /usr/local/bin/mager-agent /usr/local/bin/cloudflared

VOLUME ["/var/lib/mager"]

# cloudflared talks to Cloudflare over outbound HTTPS only; no inbound ports
# need to be exposed.

# OCI labels — the `image.source` label is what GHCR uses to attach this
# package to a GitHub repository in the package sidebar. We intentionally
# point at `huukhanh/pub-pkg` (a public packages hub) rather than the
# mager source repo, so every package published under huukhanh/* shares
# one discoverable parent.
LABEL org.opencontainers.image.title="mager-agent" \
      org.opencontainers.image.description="Mager — self-hosted Cloudflare Tunnel control-plane agent." \
      org.opencontainers.image.source="https://github.com/huukhanh/pub-pkg" \
      org.opencontainers.image.url="https://github.com/huukhanh/pub-pkg/pkgs/container/mager-agent" \
      org.opencontainers.image.documentation="https://github.com/huukhanh/mager#run-the-agent-in-docker" \
      org.opencontainers.image.licenses="MIT"

ENTRYPOINT ["/entrypoint.sh"]
