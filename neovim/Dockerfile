ARG FEDORA_VERSION=44
ARG DIGEST=sha256:a100965548dcfb6cd9c4340b17d438b8e40893cded7ac7808a4e8012b7100c19
FROM fedora:${FEDORA_VERSION}@${DIGEST}

ENV SHELL="/bin/bash"

RUN dnf -y --setopt=install_weak_deps=False update; \
    dnf -y --setopt=install_weak_deps=False install neovim git shadow-utils; \
    dnf clean all; \
    rm -rf /var/cache/dnf; \

RUN groupadd --gid 1000 neovim && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash neovim && \
    chmod 0755 /home/neovim

USER neovim

WORKDIR /home/neovim/workdir

ENTRYPOINT ["nvim"]

