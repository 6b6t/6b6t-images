FROM eclipse-temurin:25

# Setup groups and install dumb init
RUN groupadd -g 1001 runner && \
    useradd -u 1001 -g runner -s /bin/sh -m runner && \
    apt-get update && \
    apt-get install -y dumb-init unzip zip git curl python3 python3-pip ca-certificates gnupg jq tar socat conntrack iptables git htop nano wget tcpdump

# Use the runner's home data directory as our work directory
WORKDIR /home/runner/data

# Switch from root to user
USER runner

# Install mcstatus
RUN pip3 install --no-cache-dir --break-system-packages mcstatus

ENV PATH="${PATH}:/home/runner/.local/bin"

# Start the process using dumb-init
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/sh", "/home/runner/data/start.sh"]
