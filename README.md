> [!IMPORTANT]
> This repository has moved to **[git.6b6t.org/6b6t/6b6t-images](https://git.6b6t.org/6b6t/6b6t-images)**. This GitHub copy is archived and no longer updated.

# 6b6t-images

Docker images used by 6b6t infrastructure.

## Images

### Java

Base image for running Java applications with Eclipse Temurin 27.

```bash
docker pull ghcr.io/6b6t/java:latest
```

Features:
- Eclipse Temurin 27
- dumb-init for proper signal handling
- Common utilities: git, curl, unzip, zip, python3
- mcstatus for Minecraft server status checks
- Non-root user (`runner`) for security

The image sets `JDK_JAVA_OPTIONS=-XX:-UseBASE64Intrinsics` to mitigate [Java4Shell (CVE-2026-114938)](https://calif.io/java4shell/).
This disables the affected Base64 optimization until Temurin publishes a patched Java 27 release.
Keep this flag if you override `JDK_JAVA_OPTIONS`.
Workloads can set `JAVA_TOOL_OPTIONS` without removing the mitigation.

Build the image and test the mitigation:

```bash
docker build --pull --no-cache --tag 6b6t-java:test java
bash java/test.sh 6b6t-java:test
```

The publishing workflow runs this test before it publishes the Java image.

### MySQL Client

Image with MariaDB client for database operations.

```bash
docker pull ghcr.io/6b6t/mysql-client:latest
```

Features:
- Debian Trixie base
- MariaDB client
- dumb-init for proper signal handling
- Common utilities: git, curl, unzip, zip, python3

Set `MYSQL_CLIENT_MSG` environment variable to customize the connection hint displayed on startup.

### UNFS3

Userspace NFSv3 server for existing server data, without privileged container mode.
See the [UNFS3 configuration and test instructions](unfs3/README.md).

## License

MIT

## Local Git checks

Install [Lefthook](https://lefthook.dev/installation/) 1.13.6 or newer and Python 3.10 or newer.
Run `lefthook install` once in each clone or linked worktree.

The commit hook checks staged whitespace without rewriting or staging files.
The push hook reads Git's exact ref updates and selects existing checks for changed paths, including deletions.
New remote refs and unavailable baselines check the complete tree.
Check out the commit that you push, then commit or stash tracked and untracked changes.
This makes the working files match the pushed revision. Deletion-only pushes do not run code checks.
Hook regression tests run for pushes with changed files. Documentation changes do not compile the application. CI remains enabled.

Install ShellCheck and Hadolint.
Shell changes run ShellCheck. Dockerfile changes run Hadolint.
Hadolint errors block pushes, while style warnings remain advisory.
The hooks do not build or publish images. Run container integration tests explicitly with the commands in each image guide.

Preview the complete local check plan:

```bash
python3 scripts/check-push.py --all --dry-run --verbose
```

Run all checks against working files before committing:

```bash
python3 scripts/check-push.py --all
```

The explicit `--all` mode allows uncommitted files. Normal push hooks require a clean working tree.
