ARG FEDORA_VERSION=44
ARG DIGEST=sha256:a100965548dcfb6cd9c4340b17d438b8e40893cded7ac7808a4e8012b7100c19
FROM fedora:${FEDORA_VERSION}@${DIGEST}

ENV SHELL="/bin/bash" \
    HOME=/home/grok \
    GROK_HOME=/home/grok/.grok \
    XDG_RUNTIME_DIR=/run/user/1000 \
    PATH="/usr/local/bin:/home/grok/.grok/bin:${PATH}"

RUN set -euxo pipefail; \
    dnf -y --setopt=install_weak_deps=False update; \
    dnf -y --setopt=install_weak_deps=False install shadow-utils git; \
    dnf clean all; \
    dnf -y autoremove; \
    dnf clean all; \
    rm -rf /var/cache/dnf

RUN groupadd --gid 1000 grok && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash grok && \
    chmod 0755 /home/grok && \
    mkdir -p /home/grok/.grok /home/grok/workdir /run/user/1000 && \
    chown -R grok:grok /home/grok /run/user/1000 && \
    chmod 0700 /home/grok/.grok /run/user/1000

# Install as the grok user so ~/.grok is not created root-owned.
USER grok
WORKDIR /home/grok
RUN curl -fsSL https://x.ai/cli/install.sh | bash

# Keep a real binary in /usr/local/bin. The named volume at ~/.grok would
# otherwise hide $HOME/.grok/bin and break `grok` on an empty volume.
USER root
RUN set -euxo pipefail; \
    grok_bin="$(readlink -f /home/grok/.grok/bin/grok)"; \
    install -m 0755 "$grok_bin" /usr/local/bin/grok; \
    ln -sf grok /usr/local/bin/agent; \
    chown -R grok:grok /home/grok/.grok

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 0755 /usr/local/bin/docker-entrypoint.sh

WORKDIR /home/grok/workdir

# Start as root so the entrypoint can chown a root-owned ~/.grok volume,
# then drop to uid 1000 before exec'ing the command.
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]
