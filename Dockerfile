# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/unrar:latest AS unrar

FROM ghcr.io/linuxserver/baseimage-alpine:edge

ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# 安装构建依赖和基本包
RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    ca-certificates \
    cmake \
    curl-dev \
    fmt-dev \
    g++ \
    gettext-dev \
    git \
    libevent-dev \
    libpsl \
    linux-headers \
    miniupnpc-dev \
    ninja \
    npm \
    pkgconfig \
    xz && \
  echo "**** install packages ****" && \
  apk add --no-cache \
    findutils \
    p7zip \
    python3 \
    curl \
    fmt \
    libevent \
    libpsl \
    miniupnpc

# 复制本地transmission源码（包括子模块）
COPY transmission/ /tmp/transmission/
WORKDIR /tmp/transmission

# 确保Git子模块已初始化并更新
RUN \
  echo "**** Check submodules ****" && \
  git config --global --add safe.directory /tmp/transmission && \
  git config --global --add safe.directory /tmp/transmission/third-party/libdeflate && \
  ls -la third-party/libdeflate

RUN \
  echo "**** build and install transmission ****" && \
  cmake -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DENABLE_DAEMON=ON \
    -DENABLE_UTILS=ON \
    -DENABLE_CLI=ON \
    -DENABLE_GTK=OFF \
    -DENABLE_QT=OFF \
    -DENABLE_WEB=ON \
    -DINSTALL_DOC=ON \
    -DUSE_SYSTEM_B64=OFF \
    -DUSE_SYSTEM_NATPMP=OFF \
    -DUSE_SYSTEM_MINIUPNPC=OFF && \
  cmake --build build && \
  cmake --install build && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# copy local files
COPY root/ /

# add unrar
COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# ports and volumes
EXPOSE 9091 51413/tcp 51413/udp
VOLUME /config
