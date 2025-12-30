# 6b6t-images

Docker images used by 6b6t infrastructure.

## Images

### Java

Base image for running Java applications with Eclipse Temurin 25.

```bash
docker pull ghcr.io/6b6t/java:latest
```

Features:
- Eclipse Temurin 25
- dumb-init for proper signal handling
- Common utilities: git, curl, unzip, zip, python3
- mcstatus for Minecraft server status checks
- Non-root user (`runner`) for security

### MySQL Client

Image with MariaDB client for database operations.

```bash
docker pull ghcr.io/6b6t/mysql-client:latest
```

Features:
- Debian Bookworm base
- MariaDB client
- dumb-init for proper signal handling
- Common utilities: git, curl, unzip, zip, python3

Set `MYSQL_CLIENT_MSG` environment variable to customize the connection hint displayed on startup.

## License

MIT
