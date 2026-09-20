ARG RUBY_VERSION=latest
FROM ruby:${RUBY_VERSION}

RUN install_packages() { apt-get update && apt-get install -y --no-install-recommends chromium unzip; } \
 && { install_packages \
   || { . /etc/os-release \
     && echo "deb http://archive.debian.org/debian $VERSION_CODENAME main" > /etc/apt/sources.list \
     && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99archive \
     && install_packages; }; } \
 && rm -rf /var/lib/apt/lists/*

RUN if ruby -e 'exit(RUBY_VERSION < "3.0")'; then gem install bundler -v 2.4.22 --no-document; fi

COPY install-chrome.sh /tmp/install-chrome.sh
RUN bash /tmp/install-chrome.sh && rm /tmp/install-chrome.sh
