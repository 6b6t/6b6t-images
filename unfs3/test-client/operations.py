"""Exercise NFS operations used by file management and shared server files."""

import errno
import os
from pathlib import Path


root = Path("/mnt")
data = os.urandom(2 * 1024 * 1024)
source = root / "source"
destination = root / "destination"
source.mkdir()
destination.mkdir()
file = source / "data"
with file.open("wb") as output:
    output.write(data)
    output.flush()
    os.fsync(output.fileno())
assert file.read_bytes() == data

# Keep a handle open while another process moves the file between directories.
with file.open("rb") as handle:
    moved = destination / "moved"
    file.rename(moved)
    assert handle.read() == data
assert moved.read_bytes() == data

link = root / "link"
link.symlink_to("destination/moved")
assert link.read_bytes() == data
assert os.readlink(link) == "destination/moved"

# Match the UID/GID used by the Java image, including a private directory.
private = root / "private"
private.mkdir(mode=0o700)
os.chown(private, 1001, 1001)
os.setegid(1001)
os.seteuid(1001)
owned = private / "owned"
owned.write_bytes(data[:4096])
owned.chmod(0o600)
assert owned.stat().st_uid == 1001
assert owned.stat().st_gid == 1001
assert owned.read_bytes() == data[:4096]
os.seteuid(0)
os.setegid(0)
assert owned.read_bytes() == data[:4096]

replacement = root / "replacement"
replacement.write_bytes(b"replacement")
os.replace(replacement, moved)
assert link.read_bytes() == b"replacement"
assert {p.name for p in root.iterdir()} == {"source", "destination", "private", "link"}

# Secondary proxies use read-only mounts of the primary's files.
assert (Path("/mnt-ro") / "link").read_bytes() == b"replacement"
try:
    (Path("/mnt-ro") / "forbidden").touch()
except OSError as error:
    assert error.errno == errno.EROFS, error
else:
    raise AssertionError("Read-only NFS mount accepted a write")

link.unlink()
owned.unlink()
private.rmdir()
moved.unlink()
source.rmdir()
destination.rmdir()
assert not list(root.iterdir())
print("NFSv3 read/write, fsync, rename, symlink, ownership, and read-only mount checks passed")
