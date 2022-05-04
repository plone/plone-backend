from pathlib import Path
import re


DOCKERFILE = Path("Dockerfile").resolve()

PATTERN = r"ENV PLONE_VERSION=([^\n]*)"


def extract_version(path: Path) -> str:
    """Extract version from Dockerfile."""
    data = open(path, "r").read()
    match = re.search(PATTERN, data)
    return match.groups()[0]

print(extract_version(DOCKERFILE))
