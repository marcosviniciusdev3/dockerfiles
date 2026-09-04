FROM fedora:44

RUN printf "[google-cloud-cli]\nname=Google Cloud CLI\nbaseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=0\ngpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg\n" > /etc/yum.repos.d/google-cloud-sdk.repo && \
    CLOUDSDK_SKIP_PY_COMPILATION=1 dnf install -y libxcrypt-compat.x86_64 google-cloud-cli && \
    dnf clean all

COPY ./build/ /bin/
