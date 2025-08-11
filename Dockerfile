FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
STOPSIGNAL SIGRTMIN+3

RUN apt-get update && apt-get install -y --no-install-recommends \
    systemd \
    systemd-sysv \
    curl \
    gnupg \
    lsb-release \
    ca-certificates \
    apt-utils && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://inverse.ca/downloads/GPG_PUBLIC_KEY | gpg --dearmor -o /usr/share/keyrings/packetfence-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/packetfence-archive-keyring.gpg] https://inverse.ca/downloads/PacketFence/debian/14.1 $(lsb_release -cs) $(lsb_release -cs)" | tee /etc/apt/sources.list.d/packetfence.list

WORKDIR /build
RUN apt-get update && apt-get download packetfence && \
    dpkg-deb -R ./*.deb ./unpacked && \
    echo '#!/bin/sh\nexit 0' > ./unpacked/DEBIAN/preinst && \
    echo '#!/bin/sh\nexit 0' > ./unpacked/DEBIAN/postinst && \
    dpkg-deb -b ./unpacked ./packetfence-fixed.deb

RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d && \
    apt-get install -y ./packetfence-fixed.deb && \
    rm /usr/sbin/policy-rc.d

RUN a2enmod ssl && \
    a2ensite default-ssl

WORKDIR /
RUN rm -rf /build
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/sbin/init"]
