# syntax=docker/dockerfile:1

### Step 1: Fetch unrar binary ###
FROM ghcr.io/linuxserver/unrar:latest AS unrar

### Step 2: Build transmission from source ###
FROM ghcr.io/linuxserver/baseimage-alpine:edge AS builder

ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# Step 2.1: Install build dependencies
RUN echo "==> Installing build dependencies..." && \
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
    apk add --no-cache \
    findutils \
    p7zip \
    python3 \
    curl \
    fmt \
    libevent \
    libpsl \
    miniupnpc

# Step 2.2: Copy transmission source (including submodules)
COPY transmission/ /tmp/transmission/
WORKDIR /tmp/transmission

# Step 2.3: Build and install transmission
RUN echo "==> Building transmission..." && \
    cmake -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/build \
    -DENABLE_DAEMON=ON \
    -DENABLE_UTILS=ON \
    -DENABLE_CLI=ON \
    -DENABLE_GTK=OFF \
    -DENABLE_QT=OFF \
    -DENABLE_WEB=ON \
    -DINSTALL_DOC=OFF \
    -DUSE_SYSTEM_B64=OFF \
    -DUSE_SYSTEM_NATPMP=OFF \
    -DUSE_SYSTEM_MINIUPNPC=OFF && \
    cmake --build build && \
    cmake --install build

### Step 3: Create final runtime image ###
FROM ghcr.io/linuxserver/baseimage-alpine:edge

ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# Step 3.1: Install runtime dependencies
RUN echo "==> Installing runtime dependencies..." && \
    apk add --no-cache \
    findutils \
    p7zip \
    python3 \
    curl \
    fmt \
    libevent \
    libpsl \
    miniupnpc

# Step 3.2: Copy compiled transmission from builder
COPY --from=builder /build/ /usr/

# Step 3.3: Add unrar binary
COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# Step 3.4: Copy additional configuration and scripts
COPY root/ /

# Step 3.5: Expose ports and set volume
EXPOSE 9091 51413/tcp 51413/udp
VOLUME /config
