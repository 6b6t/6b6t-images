FROM debian:13@sha256:9c6e381421d0f48d1b8133e573f33c185ee16cbf505eda9c4a8a4791b25ea8a6

# Setup groups and install dumb init
RUN apt-get update && \
    apt-get install -y dumb-init unzip zip git curl python3 python3-pip ca-certificates gnupg jq tar socat conntrack iptables git htop nano wget tcpdump mariadb-client

# Start the process using dumb-init
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash"]
