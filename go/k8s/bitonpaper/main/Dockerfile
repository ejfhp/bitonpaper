
FROM gcr.io/bitcoinonpaper/flutter-build_main:latest as builder

ARG ver=""

WORKDIR /bitonpaper
COPY . .
RUN ls -l
WORKDIR /bitonpaper/flutter

RUN echo "const String VERSION = \"${ver}\";" > ./lib/version.dart

RUN flutter build web

# Copy local code to the container image.
WORKDIR /bitonpaper/go

# Build the command inside the container.
# (You may fetch or manage dependencies here,
# either manually or with a tool like "godep".)
RUN mkdir /go
RUN pwd
RUN ls -l
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux  go build -o bitonpaper ./cmd/bitonpaper

# Use a Docker multi-stage build to create a lean production image.
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM alpine:3.12
RUN apk add --no-cache ca-certificates

# Copy the binary to the production image from the builder stage.
RUN mkdir /bitonpaper
WORKDIR /bitonpaper
COPY --from=builder /bitonpaper/go/bitonpaper bitonpaper
COPY --from=builder /bitonpaper/flutter/build/web web

# Run the web service on container startup.
CMD ["/bitonpaper/bitonpaper"]
