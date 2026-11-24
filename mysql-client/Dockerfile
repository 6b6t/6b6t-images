FROM debian:13@sha256:3cda3ca472ce45507a5109c6a3907093e24d9ae67d55954c9a07a45665dafba2

# Setup groups and install dumb init
RUN apt-get update && \
    apt-get install -y dumb-init unzip zip git curl python3 python3-pip ca-certificates gnupg jq tar socat conntrack iptables git htop nano wget tcpdump mariadb-client

# Start the process using dumb-init
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash"]
