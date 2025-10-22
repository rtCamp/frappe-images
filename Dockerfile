# Generated 2025-09-29T09:03:32.93404
# python: 3.12.11
# nodejs: 22.19.0
FROM python:3.12.11-slim
LABEL org.opencontainers.image.authors="rtCamp <sys@rtcamp.com>"

RUN groupadd --gid 1000 frappe && useradd --uid 1000 --gid frappe --shell /bin/bash -d /workspace frappe

RUN \
  apt-get update && apt-get install curl gnupg2 xz-utils -yqq && \
 \
  rm -rf /var/lib/apt/lists/*
RUN NODE_VERSION="v22.19.0" \
  ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    arm64) ARCH='arm64';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  && for key in $(curl -sL https://raw.githubusercontent.com/nodejs/docker-node/HEAD/keys/node.keys); do \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-linux-$ARCH.tar.xz" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs
RUN corepack enable yarn
RUN pip install --no-cache-dir -U pip uv frappe-bench
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    # Core Utilities
  ca-certificates wget git gettext-base \
  # Database Clients (required for bench commands)
  mariadb-client postgresql-client \
  # PDF runtime dependencies (for wkhtmltopdf)
  libssl3 libpangocairo-1.0-0 xfonts-75dpi xfonts-base fonts-cantarell \
  # Process Management
  jq gosu \
  pkg-config \
  # For pandas
  libbz2-dev \
  # For bench execute
  libsqlite3-dev \
  # For other dependencies
  zlib1g-dev \
  build-essential \
  #  libreadline-dev \
  #  llvm \
  #  libncurses5-dev \
  #  libncursesw5-dev \
  #  xz-utils \
  #  tk-dev \
  #  liblzma-dev \
  # Other
  libffi-dev \
  liblcms2-dev \
  libldap2-dev \
  libmariadb-dev \
  libsasl2-dev \
  libtiff5-dev \
  libwebp-dev \
  redis-tools \
  rlwrap \
  tk8.6-dev \
  ssh-client \
  # Check if required ?
  && rm -rf /var/lib/apt/lists/*

ENV WKHTMLTOPDF_VERSION=0.12.6.1-3
RUN set -eux; \
    ARCH=$(dpkg --print-architecture); \
    downloaded_file=wkhtmltox_${WKHTMLTOPDF_VERSION}.bookworm_${ARCH}.deb; \
    wget -q https://github.com/wkhtmltopdf/packaging/releases/download/${WKHTMLTOPDF_VERSION}/${downloaded_file}; \
    dpkg -i $downloaded_file || apt-get install -y --no-install-recommends -f; \
    rm $downloaded_file

WORKDIR /workspace
