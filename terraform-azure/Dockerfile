FROM hashicorp/terraform:1.15.8 AS terraform

FROM mcr.microsoft.com/azure-cli:2.68.0

LABEL maintainer=github.com/marcosviniciusdev3

COPY --from=terraform /bin/terraform /usr/local/bin/terraform

ENTRYPOINT ["/usr/local/bin/terraform"]
