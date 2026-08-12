#!/usr/bin/env python3
"""Builds RPM and/or DEB packages for this app via nfpm.

Usage:
    flutter-elinux build elinux --release
    python3 packaging/package.py                              # rpm + deb, release "1", into ./dist
    python3 packaging/package.py ./out --formats rpm           # just rpm, into ./out
    python3 packaging/package.py --formats rpm --release "$(
        python3 packaging/resolve_version.py --format rpm | python3 -c 'import json,sys; print(json.load(sys.stdin)["release"])'
    )"
"""

import argparse
import logging
import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _common import NFPM_CONFIG, REPO_ROOT, read_upstream_version  # noqa: E402

STAGE_DIR = REPO_ROOT / "stage"

log = logging.getLogger("package")


def configure_logging(verbose: bool) -> None:
    logging.basicConfig(
        level=logging.DEBUG if verbose else logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%H:%M:%S",
    )


def find_bundle_dir() -> Path:
    matches = sorted(REPO_ROOT.glob("build/elinux/*/release/bundle"))
    if not matches:
        raise SystemExit(
            "No build bundle found under build/elinux/*/release/bundle. "
            "Run `flutter-elinux build elinux --release` first."
        )
    return matches[0]


def stage_bundle(bundle_dir: Path) -> None:
    if STAGE_DIR.exists():
        shutil.rmtree(STAGE_DIR)
    STAGE_DIR.mkdir(parents=True)
    shutil.copytree(bundle_dir, STAGE_DIR / "bundle")
    log.info("Staged bundle from %s", bundle_dir.relative_to(REPO_ROOT))


def build_package(fmt: str, version: str, release: str, arch: str, output_dir: Path) -> None:
    log.info("Building %s package (version %s, release %s)...", fmt, version, release)
    env = {**os.environ, "PKG_VERSION": version, "PKG_RELEASE": release, "PKG_ARCH": arch}
    result = subprocess.run(
        ["nfpm", "pkg", "--config", str(NFPM_CONFIG), "--packager", fmt, "--target", str(output_dir)],
        cwd=REPO_ROOT,
        env=env,
        capture_output=True,
        text=True,
    )
    for line in result.stdout.splitlines():
        log.debug("nfpm: %s", line)
    if result.returncode != 0:
        log.error("nfpm failed for %s:\n%s", fmt, result.stderr.strip())
        raise SystemExit(result.returncode)
    log.info("Built %s package", fmt)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("output_dir", nargs="?", default="./dist", help="Where to write the built packages")
    parser.add_argument("--formats", default="rpm,deb", help="Comma-separated list of packagers to run")
    parser.add_argument("--version", default=None, help="Upstream version; defaults to pubspec.yaml")
    parser.add_argument("--release", default="1", help="Package release/revision; defaults to 1")
    parser.add_argument("-v", "--verbose", action="store_true", help="Show nfpm's own output")
    args = parser.parse_args()

    configure_logging(args.verbose)

    if not NFPM_CONFIG.exists():
        raise SystemExit(f"{NFPM_CONFIG} not found")
    if shutil.which("nfpm") is None:
        raise SystemExit("nfpm not found on PATH. Install it: https://nfpm.goreleaser.com/install/")

    version = args.version or read_upstream_version()
    arch = platform.machine()
    log.info("Version: %s  Release: %s  Arch: %s", version, args.release, arch)

    stage_bundle(find_bundle_dir())

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    try:
        for fmt in args.formats.split(","):
            build_package(fmt, version, args.release, arch, output_dir)
    finally:
        shutil.rmtree(STAGE_DIR, ignore_errors=True)

    log.info("Packaging complete")


if __name__ == "__main__":
    main()
