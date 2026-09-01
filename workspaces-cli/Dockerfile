FROM  fedora:44 

COPY ./build/gws /bin

RUN sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM

RUN sudo CLOUDSDK_SKIP_PY_COMPILATION=1 dnf install -y libxcrypt-compat.x86_64 google-cloud-cli
