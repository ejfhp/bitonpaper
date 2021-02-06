
FROM debian  as builder
RUN apt-get update
RUN apt-get install -y unzip xz-utils git openssh-client curl wget lib32stdc++6 libglu1-mesa default-jdk-headless

# Install GO
WORKDIR /opt
RUN wget "https://dl.google.com/go/$(curl https://golang.org/VERSION?m=text).linux-amd64.tar.gz" -O go.tar.gz
RUN tar xf go.tar.gz
ENV GOROOT="/opt/go"
ENV PATH="${GOROOT}/bin:${PATH}"
ENV GOPATH="/go"


# Install Flutter
# RUN curl https://storage.googleapis.com/flutter_infra/releases/beta/linux/flutter_linux_1.22.0-12.4.pre-beta.tar.xz -o flutter.tar.xz
WORKDIR /opt
RUN curl https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_1.22.5-stable.tar.xz -o flutter.tar.xz
RUN tar xf flutter.tar.xz
ENV FLUTTER_ROOT="/opt/flutter"
ENV PATH="${PATH}:${FLUTTER_ROOT}/bin"
RUN flutter config  --no-analytics
RUN flutter config --enable-web
RUN flutter channel beta
RUN flutter precache
RUN yes "y" | flutter doctor --android-licenses

RUN flutter upgrade
RUN flutter doctor -v

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
