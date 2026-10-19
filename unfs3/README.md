# UNFS3

This image serves existing server data through UNFS3 0.11.0, a userspace NFSv3 server.
The build verifies the upstream release archive with SHA-256 and uses a pinned Alpine base image.
The image contains the upstream BSD license.

The daemon runs in the foreground and serves NFS and MOUNT on TCP port 2049.
It does not use rpcbind, UDP, the kernel NFS server, or `SYS_ADMIN`.
The default export is `/export`, with read/write access and `no_root_squash`.
Network policies must limit access to trusted clients.

## Container configuration

Mount the existing data directory at `/export`.
For another export path, mount an exports file at `/etc/exports` and mount the data at that path.
For another port, override both the `-n` and `-m` arguments.

The Kubernetes chart runs the container as UID/GID 0 with these capabilities:

```text
CHOWN DAC_OVERRIDE FOWNER FSETID SETGID SETUID
```

These capabilities preserve client ownership and permission operations on existing files.
The container drops all other capabilities and uses a read-only root filesystem with privilege escalation disabled.
This configuration satisfies Pod Security Baseline.

## Client configuration

Clients use the following mount configuration:

```text
nfsvers=3,proto=tcp,mountproto=tcp,mountvers=3,port=2049,mountport=2049,nolock,hard
```

The export path is `/export`. UNFS3 does not provide the NFSv4 pseudo-root at `/`.
UNFS3 does not support network file locking. `nolock` provides only client-local locks.
Applications that require locks across clients need a different server.
Existing NFSv4 mounts need an unmount and a new NFSv3 mount during migration.

## Build and integration test

```bash
docker build --tag unfs3:test unfs3
./unfs3/test.sh unfs3:test
```

The test uses disposable Docker data and mounts from a separate Linux NFS client container.
Only that client receives `SYS_ADMIN`, which the kernel requires for mounts.
The exporter uses the same capabilities as the chart.
The test covers writes, `fsync`, renames, symlinks, ownership, cleanup, and read-only access.

## Publishing

Changes to `unfs3/` on `main` run the dedicated publishing workflow.
The workflow runs the integration test before it publishes `ghcr.io/6b6t/unfs3`.
Tags include `latest` and the short source revision.
Production chart values pin the published image digest.
