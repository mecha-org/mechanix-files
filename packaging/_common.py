"""Small helpers shared between packaging/package.py and packaging/resolve_version.py."""

import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
NFPM_CONFIG = REPO_ROOT / "packaging" / "nfpm" / "nfpm.yaml"


def read_upstream_version() -> str:
    pubspec = REPO_ROOT / "pubspec.yaml"
    match = re.search(r"^version:\s*(\S+)", pubspec.read_text(), re.MULTILINE)
    if not match:
        raise SystemExit(f"No version field found in {pubspec}")
    return match.group(1).split("+")[0]


def read_package_name() -> str:
    match = re.search(r"^name:\s*(\S+)", NFPM_CONFIG.read_text(), re.MULTILINE)
    if not match:
        raise SystemExit(f"No name field found in {NFPM_CONFIG}")
    return match.group(1)
