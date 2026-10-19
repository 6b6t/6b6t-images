"""Keep a metadata working set larger than the upstream file-handle cache."""

from pathlib import Path


root = Path("/mnt/metadata")
root.mkdir()
files = [root / f"file-{number}" for number in range(8192)]
for file in files:
    file.touch()

# actimeo=0 on the client mount makes stat() reach the server for every file.
assert len({file.stat().st_ino for file in files}) == len(files)

for file in files:
    file.unlink()
root.rmdir()
print(f"Metadata checks passed for {len(files)} file handles")
