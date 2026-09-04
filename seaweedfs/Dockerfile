FROM golang:alpine as builder

WORKDIR /src/seaweedfs
ENV GOTOOLCHAIN=auto
RUN apk update && apk add --no-cache git make
RUN git clone https://github.com/seaweedfs/seaweedfs.git . && \
    git checkout df879e1ed70f15bc7470f5f7edb0df9c159a76f2 && \
    make -C weed install

FROM alpine:3.23.4
COPY --from=builder /go/bin/weed /usr/local/bin
ENTRYPOINT ["weed"]
