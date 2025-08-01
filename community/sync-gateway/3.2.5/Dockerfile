FROM ubuntu:22.04

LABEL maintainer="docker@couchbase.com"

ENV PATH $PATH:/opt/couchbase-sync-gateway/bin

# Install dependencies:
#  wget: for downloading Sync Gateway package installer
RUN set -x \
    && apt update \
    && apt install -y \
           curl \
           lsb-release \
           systemctl \
           wget \
    && apt clean

# Install Sync Gateway
ARG SGW_PACKAGE="http://packages.couchbase.com/releases/couchbase-sync-gateway/3.2.5/couchbase-sync-gateway-community_3.2.5_@@ARCH@@.deb"
RUN set -x \
    && SGW_PACKAGE=$(echo "${SGW_PACKAGE}" | sed -e "s/@@ARCH@@/$(uname -m)/") \
    && SGW_PACKAGE_FILENAME=$(echo "couchbase-sync-gateway-community_3.2.5_@@ARCH@@.deb" | sed -e "s/@@ARCH@@/$(uname -m)/") \
    && wget "${SGW_PACKAGE}" \
    && apt install -y ./"${SGW_PACKAGE_FILENAME}" \
    && rm "${SGW_PACKAGE_FILENAME}" \
    && apt autoremove \
    && apt clean

# Create directory where the default config stores memory snapshots to disk
RUN mkdir /opt/couchbase-sync-gateway/data

# Copy sample service config as the initial config
RUN mkdir /etc/sync_gateway \
    && cp /opt/couchbase-sync-gateway/examples/startup_config/basic.json /etc/sync_gateway/config.json \
    && chown -R sync_gateway:sync_gateway /etc/sync_gateway

# Create log dir
RUN set -x \
    && mkdir -p /var/log/sync_gateway \
    && chown sync_gateway:sync_gateway /var/log/sync_gateway

# Add bootstrap script
COPY scripts/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

# If user doesn't specify any args, use the default config
CMD ["/etc/sync_gateway/config.json"]

USER sync_gateway
WORKDIR /home/sync_gateway

VOLUME /var/log/sync_gateway
# Expose ports
#  port 4984: public port
EXPOSE 4984
