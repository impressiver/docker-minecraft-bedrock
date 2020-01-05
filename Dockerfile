FROM ubuntu
LABEL maintainer="ian@impressiver.com"

ARG BEDROCK_VERSION=1.14.1.4
ARG BEDROCK_DOWNLOAD_URL="https://minecraft.azureedge.net/bin-linux/bedrock-server-${BEDROCK_VERSION}.zip"

VOLUME ["/data"]

#ipv4
EXPOSE 19132 19132/udp
#ipv6
EXPOSE 19133 19133/udp

ENV TERM xterm-256color
ENV LD_LIBRARY_PATH=/opt/bedrock-server

# install system dependencies
RUN apt-get -y update \
  && apt-get install -y libterm-readline-gnu-perl curl unzip

# download and install minecraft server
RUN curl $BEDROCK_DOWNLOAD_URL --output /tmp/bedrock-server.zip
RUN unzip /tmp/bedrock-server.zip -d /opt/bedrock-server \
  && rm /tmp/bedrock-server.zip

COPY entrypoint.sh /opt/bedrock-server/
COPY server.properties /opt/bedrock-server/

RUN groupadd -r -g 999 minecraft \
  && useradd --no-log-init -r -u 999 -g minecraft -d /opt/bedrock-server minecraft \
  && chown -R minecraft:minecraft /opt/bedrock-server \
  && chmod ugo+rw /opt/bedrock-server \
  && chmod +x /opt/bedrock-server/entrypoint.sh

WORKDIR /opt/bedrock-server

# USER minecraft:minecraft

ENTRYPOINT ["/opt/bedrock-server/entrypoint.sh"]
CMD ["./bedrock_server"]
