FROM golang:alpine3.23 as builder

WORKDIR /src
# hadolint ignore=DL3018
RUN apk update && apk add --no-cache git make
# hadolint ignore=DL3003
RUN git clone https://github.com/seaweedfs/seaweedfs.git && \
    cd seaweedfs && git checkout df879e1ed70f15bc7470f5f7edb0df9c159a76f2 && \
    cd /src/seaweedfs/weed && make install

FROM alpine:3.23.4
COPY --from=builder /go/bin/weed /usr/local/bin
ENTRYPOINT ["weed"]
