#!/usr/bin/env python3
"""Atomically refresh the SHA-256 inventory of a COCO publication suite."""

from __future__ import annotations

import argparse
import csv
import hashlib
import os
from pathlib import Path
import tempfile


INVENTORY_NAME = "artifact_sha256.csv"


def excluded(path: Path, root: Path) -> bool:
    relative = path.relative_to(root)
    name = path.name
    return (
        name == INVENTORY_NAME
        or name == "run.log"
        or name == "checkpoint.mat"
        or name.startswith("~$")
        or name.startswith(".")
        or any(part.startswith(".") for part in relative.parts)
    )


def digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            value.update(chunk)
    return value.hexdigest()


def refresh(root: Path) -> Path:
    root = root.expanduser().resolve()
    if not root.is_dir():
        raise FileNotFoundError(f"COCO result root does not exist: {root}")
    rows: list[tuple[str, int, str]] = []
    for path in sorted(item for item in root.rglob("*") if item.is_file()):
        if excluded(path, root):
            continue
        rows.append((path.relative_to(root).as_posix(), path.stat().st_size, digest(path)))

    destination = root / INVENTORY_NAME
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=".artifact_sha256.", suffix=".tmp", dir=root
    )
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="") as handle:
            writer = csv.writer(handle)
            writer.writerow(("Relative_path", "Bytes", "SHA256"))
            writer.writerows(rows)
        os.replace(temporary_name, destination)
    except Exception:
        try:
            os.unlink(temporary_name)
        except OSError:
            pass
        raise
    return destination


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("result_root", type=Path)
    arguments = parser.parse_args()
    destination = refresh(arguments.result_root)
    print(f"Refreshed artifact inventory: {destination}")


if __name__ == "__main__":
    main()
