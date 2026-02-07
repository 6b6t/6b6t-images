FROM eclipse-temurin:25

# Setup groups and install dumb init
RUN groupadd -g 1001 runner && \
    useradd -u 1001 -g runner -s /bin/sh -m runner && \
    apt-get update && \
    apt-get install -y dumb-init unzip zip git curl python3 ca-certificates gnupg jq tar socat conntrack iptables htop nano wget tcpdump rsync

# Install mc-monitor for health checks
RUN curl -sL https://github.com/itzg/mc-monitor/releases/download/0.16.0/mc-monitor_0.16.0_linux_amd64.tar.gz | tar xzf - -C /usr/local/bin mc-monitor

# Use the runner's home data directory as our work directory
WORKDIR /home/runner/data

# Switch from root to user
USER runner

# Start the process using dumb-init
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/bash", "/home/runner/data/start.sh"]
