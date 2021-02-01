
FROM debian 
RUN apt-get update
RUN apt-get install -y unzip xz-utils git openssh-client curl wget
WORKDIR /opt


RUN wget "https://dl.google.com/go/$(curl https://golang.org/VERSION?m=text).linux-amd64.tar.gz" -O go.tar.gz
RUN tar xf go.tar.gz
ENV GOROOT="/opt/go"
ENV PATH="${GOROOT}/bin:${PATH}"
ENV GOPATH="/go"

# RUN curl https://storage.googleapis.com/flutter_infra/releases/beta/linux/flutter_linux_1.22.0-12.4.pre-beta.tar.xz -o flutter.tar.xz
RUN curl https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_1.22.5-stable.tar.xz -o flutter.tar.xz
RUN tar xf flutter.tar.xz
ENV FLUTTER_ROOT="/opt/flutter"
ENV PATH="${FLUTTER_ROOT}/bin:${PATH}"
RUN flutter config  --no-analytics
RUN flutter config --enable-web
RUN flutter channel beta
RUN flutter upgrade