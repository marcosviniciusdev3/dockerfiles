# syntax=docker/dockerfile:1

# Build Arguments
ARG DOTNET_VERSION=8.0
ARG NODE_VERSION=20-alpine
ARG DEBIAN_VERSION=bookworm-slim
ARG JELLYFIN_VERSION=v10.10.6
ARG JELLYFIN_WEB_VERSION=v10.10.6
ARG FFMPEG_PACKAGE=jellyfin-ffmpeg7

# ==============================================================================
# Stage 1: Build Jellyfin Web UI static assets
# ==============================================================================
FROM node:${NODE_VERSION} AS web-builder

ARG JELLYFIN_WEB_REPO=https://github.com/jellyfin/jellyfin-web.git
ARG JELLYFIN_WEB_VERSION

WORKDIR /src

RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    autoconf \
    automake \
    libtool \
    nasm

RUN git clone --depth 1 --branch ${JELLYFIN_WEB_VERSION} ${JELLYFIN_WEB_REPO} . \
    && npm ci --no-audit --unsafe-perm \
    && npm run build:production \
    && mv dist /web

# ==============================================================================
# Stage 2: Build Jellyfin Server .NET application
# ==============================================================================
FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION} AS server-builder

ARG JELLYFIN_REPO=https://github.com/jellyfin/jellyfin.git
ARG JELLYFIN_VERSION

WORKDIR /src

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1

RUN git clone --depth 1 --branch ${JELLYFIN_VERSION} ${JELLYFIN_REPO} . \
    && dotnet publish Jellyfin.Server \
        --configuration Release \
        --output /server \
        -p:DebugSymbols=false \
        -p:DebugType=none

# ==============================================================================
# Stage 3: Minimal Kubernetes-Tailored Runtime Image
# ==============================================================================
FROM mcr.microsoft.com/dotnet/aspnet:${DOTNET_VERSION}-${DEBIAN_VERSION} AS runtime

ARG FFMPEG_PACKAGE

LABEL org.opencontainers.image.title="Jellyfin Minimal (Kubernetes)" \
      org.opencontainers.image.description="Lightweight Jellyfin media server optimized for Kubernetes deployments" \
      org.opencontainers.image.url="https://jellyfin.org" \
      org.opencontainers.image.source="https://github.com/jellyfin/jellyfin"

# Default environment variables for Jellyfin & ASP.NET
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1 \
    ASPNETCORE_URLS="http://+:8096" \
    JELLYFIN_DATA_DIR="/config/data" \
    JELLYFIN_CONFIG_DIR="/config" \
    JELLYFIN_CACHE_DIR="/cache" \
    JELLYFIN_LOG_DIR="/config/log" \
    JELLYFIN_WEB_DIR="/jellyfin/jellyfin-web" \
    JELLYFIN_FFMPEG="/usr/lib/jellyfin-ffmpeg/ffmpeg" \
    DEBIAN_FRONTEND="noninteractive" \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en"

# Install minimal runtime dependencies and official jellyfin-ffmpeg
# Excludes heavy compute runtime stacks (Intel NEO OpenCL, Mali Rockchip, etc.)
RUN find /etc/apt/ -type f \( -name '*.sources' -o -name 'sources.list' \) -exec sed -i 's|http://deb.debian.org|https://deb.debian.org|g' {} + \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests --yes \
        ca-certificates \
        curl \
        gnupg \
        locales \
        libfontconfig1 \
        libfreetype6 \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    # Add Jellyfin official APT repo for jellyfin-ffmpeg
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://repo.jellyfin.org/jellyfin_team.gpg.key | gpg --dearmor -o /etc/apt/keyrings/jellyfin.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/jellyfin.gpg] https://repo.jellyfin.org/debian bookworm main" > /etc/apt/sources.list.d/jellyfin.list \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests --yes \
        ${FFMPEG_PACKAGE} \
    # Cleanup unnecessary packages & apt caches to keep image minimal
    && apt-get purge --yes --auto-remove curl gnupg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create non-root jellyfin user and directories with proper permissions
RUN groupadd -g 1000 jellyfin \
    && useradd -u 1000 -g jellyfin -d /config -s /usr/sbin/nologin jellyfin \
    && mkdir -p /jellyfin /config /cache /media /tmp \
    && chown -R jellyfin:jellyfin /jellyfin /config /cache /media /tmp

WORKDIR /jellyfin

# Copy artifacts from build stages
COPY --from=server-builder --chown=jellyfin:jellyfin /server /jellyfin
COPY --from=web-builder --chown=jellyfin:jellyfin /web /jellyfin/jellyfin-web

# Expose standard Jellyfin HTTP port
EXPOSE 8096

# Define persistent storage mount points
VOLUME ["/config", "/cache", "/media"]

# Switch to non-root user
USER 1000:1000

# Start Jellyfin server
ENTRYPOINT ["dotnet", "/jellyfin/jellyfin.dll"]
