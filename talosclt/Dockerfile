ARG FEDORA_VERSION=44
ARG DIGEST=sha256:a100965548dcfb6cd9c4340b17d438b8e40893cded7ac7808a4e8012b7100c19
FROM fedora:${FEDORA_VERSION}@${DIGEST}

LABEL org.opencontainers.image.title="talosctl"
LABEL org.opencontainers.image.description="Talos Linux CLI"
LABEL org.opencontainers.image.source="https://github.com/marcosviniciusdev3/dockerfiles"
LABEL org.opencontainers.image.documentation="https://www.talos.dev/"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.authors="marcosviniciusdev3" 
LABEL org.opencontainers.image.description="TalosCTL built with no binary"
LABEL managed-by="marcosviniciusdev3"
LABEL binary-source="https://github.com/siderolabs/talos"
LABEL git-commit="a26d35862a56b7ccaed943866534a0c70c9086ed"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY talosctl /usr/bin/talosctl

RUN set -eux pipefail; \
    dnf -y --setopt=install_weak_deps=False update; \
    dnf -y --setopt=install_weak_deps=False install shadow-utils; \
    dnf clean all; \
    rm -rf /var/cache/dnf; \
    groupadd --gid 1000 talosctl; \
    useradd --uid 1000 --gid 1000 \
      --create-home --shell /bin/bash talosctl; \
    chmod 0755 /home/talosctl;

ENV HOME=/home/talosctl
WORKDIR /home/talosctl

USER 1000:1000

ENTRYPOINT ["talosctl"]
