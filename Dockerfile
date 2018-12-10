ARG baseimg=raspbian/stretch
FROM $baseimg as build
ENV DEBIAN_FRONTEND=noninteractive
RUN mkdir -p /src
RUN apt-get update
RUN apt-get install -y \
    wget git libtool autoconf cmake \
    build-essential pkg-config unzip
RUN apt-get install -y \
    liblivemedia-dev \
    libasound2-dev

WORKDIR /src
RUN wget -q https://github.com/mpromonet/libv4l2cpp/archive/master.zip
RUN unzip master.zip

RUN wget -q https://github.com/orocos-toolchain/log4cpp/archive/v2.8.3.tar.gz
RUN tar -zxf v2.8.3.tar.gz

RUN wget -q https://github.com/mpromonet/v4l2rtspserver/archive/v0.1.0.tar.gz
RUN tar -zxf v0.1.0.tar.gz

RUN wget -q http://www.live555.com/liveMedia/public/live555-latest.tar.gz
RUN tar -zxf live555-latest.tar.gz

RUN cp libv4l2cpp-master/inc/*.h v4l2rtspserver-0.1.0/inc

WORKDIR /src/log4cpp-2.8.3
RUN ./configure --enable-static --disable-shared
RUN make -j4
RUN make install

WORKDIR /src/live
RUN ./genMakefiles linux
RUN make -j4
RUN make install

WORKDIR /src/libv4l2cpp-master
RUN make -j4
RUN make install

WORKDIR /src/v4l2rtspserver-0.1.0
RUN cmake .
RUN make -j4

