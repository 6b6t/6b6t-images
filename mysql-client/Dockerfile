FROM debian:bookworm

# Setup groups and install dumb init
RUN apt-get update && \
    apt-get install -y dumb-init unzip zip git curl python3 python3-pip mariadb-client

# Start the process using dumb-init
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash"]
