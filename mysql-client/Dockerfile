FROM debian:bookworm

# Setup groups and install dumb init
RUN apt-get update && \
    apt-get install -y dumb-init unzip zip git curl python3 python3-pip mariadb-client

# Print connection instructions from environment variable on startup
ENV MYSQL_CLIENT_MSG="mysql --host=db --user=root"

# Start the process using dumb-init
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["sh", "-c", "echo \"Command is '$MYSQL_CLIENT_MSG'\" && bash"]
