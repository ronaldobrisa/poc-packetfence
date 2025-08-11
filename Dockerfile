FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN rm -f /etc/apt/sources.list.d/* && \
    echo "deb http://deb.debian.org/debian bookworm main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
  apt-utils gnupg ca-certificates \
  perl \
  libnet-ssleay-perl \
  libapache2-mod-perl2 \
  freeradius-utils \
  libdbd-mysql-perl \
  mariadb-client \
  haproxy \
  && rm -rf /var/lib/apt/lists/*

COPY deps/*.deb /tmp/deps/

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /opt/packetfence

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
