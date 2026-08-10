FROM hashicorp/terraform:latest AS terraform

FROM mcr.microsoft.com/azure-cli:latest

COPY --from=terraform /bin/terraform /usr/local/bin/terraform

ENTRYPOINT ["/usr/local/bin/terraform"]
