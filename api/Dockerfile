ARG GO_VERSION=1.21.4
ARG ALPINE_VERSION=3.18

# Builder image to compile go code
FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS builder
ENV CGO_ENABLED=0
WORKDIR /go/src/demo-api
COPY . .
RUN go install ./...

# Live image
FROM scratch
COPY --from=builder /go/bin/* /bin/
ENTRYPOINT ["/bin/demo-api"]
