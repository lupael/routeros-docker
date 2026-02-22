FROM alpine:3.20 AS build

LABEL maintainer="Lupael <support@ispbills.com>"

# Argument passed from GitHub Actions (e.g., v7.12.1)
ARG ROUTEROS_VERSION

# We clean the version here to remove the 'v' for the URL
RUN set -xe && \
    CLEAN_VER=$(echo ${ROUTEROS_VERSION} | sed 's/^v//') && \
    \
    apk add --no-cache --update \
        wget \
        unzip \
        netcat-openbsd \
        qemu-x86_64 \
        qemu-system-x86_64 \
        busybox-extras \
        iproute2 \
        iputils \
        bridge-utils \
        iptables \
        jq \
        bash \
        python3 \
        curl && \
    \
    mkdir /routeros && \
    # Constructing the URL inside the RUN command to use the CLEAN_VER
    ROUTEROS_URL="https://download.mikrotik.com/routeros/${CLEAN_VER}/chr-${CLEAN_VER}.vdi.zip" && \
    echo "Downloading: ${ROUTEROS_URL}" && \
    \
    wget --show-error --progress=dot:giga "${ROUTEROS_URL}" -O /routeros/chr.vdi.zip && \
    unzip /routeros/chr.vdi.zip -d /routeros && \
    # Move the extracted file to a consistent name so your entrypoint doesn't break
    mv /routeros/chr-${CLEAN_VER}.vdi /routeros/chr.vdi || true && \
    rm -f /routeros/chr.vdi.zip

# Persist the clean version as an environment variable for the app to use
ENV ROUTEROS_VERSION=${ROUTEROS_VERSION}
ENV VNCPASSWORD=false
ENV KEYBOARD=en-us

WORKDIR /routeros

COPY bin /routeros/bin

# Keeping your extensive port list
EXPOSE 20/tcp 21/tcp 22/tcp 23/tcp 53/tcp 53/udp 67/udp 68/udp 80/tcp 123/udp 161/udp 443/tcp 500/udp 546/udp 547/udp 1194/tcp 1194/udp 1701/udp 1723/tcp 2000/tcp 2000/udp 4500/udp 5678/udp 8080/tcp 8291/tcp 8728/tcp 8729/tcp 13231/udp

RUN chmod +x /routeros/bin/entrypoint.sh && \
    chmod +x /routeros/bin/generate-dhcpd-conf.py && \
    chmod +x /routeros/bin/qemu-ifup && \
    chmod +x /routeros/bin/qemu-ifdown

ENTRYPOINT ["/routeros/bin/entrypoint.sh"]
