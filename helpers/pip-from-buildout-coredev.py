"""Parse versions and sources from buildout.cfg and write files to be used with pip.

Manual usage: python pip-from-buildout-coredev.py
zc.buildout needs to be importable in that python.
"""
from pathlib import Path
from zc.buildout import buildout


import re


PATTERN = f"pushurl=git@(?P<repo>[^ ]*)\.git .*branch=(?P<branch>[^ ]*).*$"
IGNORE = ("docs", "jquery.recurrenceinput.js ", "mockup", "plone.themepreview")


config_file = Path("buildout.cfg").resolve()
constraints_file = Path("pip-constraints.txt").resolve()
requirements_file = Path("pip-requirements.txt").resolve()

config = buildout.Buildout(str(config_file), [])

checkouts = config["buildout"]["auto-checkout"].split("\n")

constraints = {}
for package, version in sorted(config.versions.items()):
    constraints[package] = f"{package}=={version}"

sources = {}
for package in checkouts:
    source_info = config["sources"][package]
    match=re.search(PATTERN, source_info)
    if not match:
        # Wrong format, ignore
        continue
    match = match.groupdict()
    repo = match["repo"].replace(":", "/")
    branch = match["branch"]
    # sources[package] = f"git+https://{repo}@{branch}"
    sources[package] = f"https://{repo}/archive/refs/heads/{branch}.zip"


# Generate requirements
with open(requirements_file, "w") as cfile:
    cfile.write(f"# File created by {__file__}\n")
    cfile.write(f"# Data parsed from {config_file}\n")
    for package, info in sources.items():
        if package in IGNORE:
            continue
        cfile.write(f"{info}\n")


# Generate constraints
with open(constraints_file, "w") as cfile:
    cfile.write(f"# File created by {__file__}\n")
    cfile.write(f"# Data parsed from {config_file}\n")
    for package, info in constraints.items():
        if package in sources:
            continue
        cfile.write(f"{info}\n")
