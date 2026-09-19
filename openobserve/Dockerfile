FROM alpine:3.24.1 as downloader

WORKDIR /app

RUN apk update && apk add --no-cache curl tar 

RUN curl -L -o openobserve-v1.0.0-linux-amd64-musl.tar.gz \ 
    https://downloads.openobserve.ai/releases/openobserve/v1.0.0/openobserve-v1.0.0-linux-amd64-musl.tar.gz && \ 
    tar -xzf openobserve-v1.0.0-linux-amd64-musl.tar.gz

FROM alpine:3.24.1 as application 

COPY --from=downloader /app/openobserve /usr/local/bin

RUN addgroup openobserve -g 10000 && \
    adduser -u 10000 -S -D -G openobserve openobserve

USER openobserve

EXPOSE 5080

ENTRYPOINT ["openobserve"]
