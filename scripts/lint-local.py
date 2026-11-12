#!/usr/bin/env python3
"""Lint tracked files without executing scripts, building images, or starting services."""

import argparse
from pathlib import Path
import subprocess
import shlex

ROOT = Path(__file__).resolve().parents[1]


def selected_files(kind):
    paths = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT).split(b"\0")
    selected = []
    for raw in paths:
        if not raw:
            continue
        path = Path(raw.decode("utf-8", errors="surrogateescape"))
        absolute = ROOT / path
        if not absolute.is_file():
            continue
        if kind == "shell":
            shebang = b""
            if not path.suffix:
                with absolute.open("rb") as source:
                    shebang = source.readline(256)
            matches = path.suffix == ".sh" or (
                shebang.startswith(b"#!") and b"sh" in shebang
            )
        elif kind == "docker":
            matches = path.name == "Dockerfile" or path.name.startswith("Dockerfile.")
        else:
            matches = path.suffix in (".js", ".mjs", ".cjs")
        if matches:
            selected.append(str(path))
    return selected


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kind", choices=("shell", "docker", "javascript"))
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--verbose", action="store_true")
    args = parser.parse_args()
    paths = selected_files(args.kind)
    if not paths:
        print(f"No tracked {args.kind} files.")
        return
    if args.verbose:
        for path in paths:
            print(f"Lint {args.kind}: {path}", flush=True)
    if args.kind == "shell":
        commands = [["shellcheck", *paths]]
    elif args.kind == "docker":
        # Report all advice, but block only errors during initial lint adoption.
        commands = [["hadolint", "--failure-threshold", "error", *paths]]
    else:
        commands = [["node", "--check", path] for path in paths]
    for command in commands:
        print(shlex.join(command), flush=True)
        if not args.dry_run:
            subprocess.run(command, cwd=ROOT, check=True)


if __name__ == "__main__":
    main()
