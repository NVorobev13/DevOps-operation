FROM golang:1.17.0-alpine3.14 as builder

ENV USER=user_for_app
ENV UID=10001

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/bin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

WORKDIR $GOPATH/src/app_on_go/main

COPY . .
RUN go mod download
RUN go mod verify

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /go/bin/main

FROM scratch

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /go/bin/main /go/bin/main

COPY ./static /static

USER user_for_app:user_for_app

EXPOSE 9001

ENTRYPOINT ["/go/bin/main"]
