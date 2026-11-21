FROM eclipse-temurin:27-jdk-resolute@sha256:bbd3c8267b6fdeba3502b71879255cfbfde05bec3dbe9de655ac5c007332752e

# Mitigate CVE-2026-114938 until Temurin publishes a patched Java 27 release.
# Keep this separate from the JAVA_TOOL_OPTIONS set by production workloads.
ENV JDK_JAVA_OPTIONS="-XX:-UseBASE64Intrinsics"

# Setup groups and install dumb init
RUN groupadd -g 1001 runner && \
    useradd -u 1001 -g runner -s /bin/sh -m runner && \
    apt-get update && \
    apt-get install -y dumb-init unzip zip git curl python3 ca-certificates gnupg jq tar socat conntrack iptables htop nano wget tcpdump rsync libhsdis0-fcml libnuma1 && \
    ln -sf /usr/lib/x86_64-linux-gnu/libhsdis.so.0 "$JAVA_HOME/lib/server/hsdis-amd64.so"

# Install mc-monitor for health checks
RUN curl -sL https://github.com/itzg/mc-monitor/releases/download/0.16.0/mc-monitor_0.16.0_linux_amd64.tar.gz | tar xzf - -C /usr/local/bin mc-monitor

# Use the runner's home data directory as our work directory
WORKDIR /home/runner/data

# Switch from root to user
USER runner

# Start the process using dumb-init
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/bash", "/home/runner/data/start.sh"]
