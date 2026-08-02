FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    STEAM_USER=anonymous \
    STEAM_APPID=380870 \
    STEAM_BETA=unstable \
    SERVER_NAME=myserver \
    SERVER_ADMIN_PASSWORD=changeme \
    SERVER_MAX_PLAYERS=32 \
    SERVER_PUBLIC=true \
    SERVER_PORT=16261

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    lib32gcc-s1 \
    openjdk-8-jre-headless \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/steamcmd && \
    cd /opt/steamcmd && \
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

RUN mkdir -p /opt/pzserver /data/config /data/saves

COPY scripts/ /opt/scripts/
RUN chmod +x /opt/scripts/*.sh

EXPOSE 16261/udp 16262/udp

VOLUME ["/data", "/opt/pzserver"]

WORKDIR /opt/pzserver

RUN bash /opt/scripts/entrypoint.sh
# ENTRYPOINT ["/opt/scripts/entrypoint.sh"]
