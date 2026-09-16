FROM fedora:44


RUN dnf update -y && \
    dnf install -y curl ca-certificates && \
    curl -fsSL https://gh.io/copilot-install | bash

RUN groupadd -g 10000 copilot && \
    useradd -u 10000 -g copilot -m -s /bin/bash copilot

USER copilot

