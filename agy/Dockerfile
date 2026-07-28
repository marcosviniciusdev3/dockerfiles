FROM fedora:44

RUN useradd -m -U -s /bin/bash gemini

WORKDIR /home/gemini

USER root

ENV PATH="/home/gemini/.local/bin:${PATH}"

RUN curl -fsSL https://antigravity.google/cli/install.sh | bash

RUN mkdir -p /home/gemini/.local/bin && \ 
      mv /root/.local/bin/agy /home/gemini/.local/bin && \
      chown $USER:$USER /home/gemini/.local/bin/agy && \
      echo "Configuration file stored at /home/gemini/.gemini"

USER gemini

CMD ["/home/gemini/.local/bin/agy"]
