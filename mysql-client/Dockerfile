FROM debian:trixie

# Setup groups and install dumb init
RUN apt-get update && \
    apt-get install -y dumb-init unzip zip git curl python3 python3-pip ca-certificates gnupg jq tar socat conntrack iptables git htop nano wget tcpdump mariadb-client

# Start the process using dumb-init
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash"]
