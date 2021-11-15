#!/bin/env python3
"""Print the string ",latest" if the version given
as argument is the latest version, otherwise print nothing.
Example invocation:

    is_latest.py 5.2/5.2.6 39
"""
import sys
import collect_matrix
from distutils.version import StrictVersion


def is_latest(plone_version_to_examine: str, python_version_to_examine: str):
    available_versions = []
    for el in collect_matrix.get_matrix():
        try:
            version = StrictVersion(el['plone-version'].split("/")[1])
        except ValueError:
            continue
        if not version.prerelease:
            available_versions.append((version, int(el['python-version'])))
    available_versions.sort()
    latest_plone_version = str(available_versions[-1][0])
    latest_python_version = str(available_versions[-1][1])
    if latest_plone_version == plone_version_to_examine and python_version_to_examine == str(latest_python_version):
        return True

if __name__ == '__main__':
    if is_latest(sys.argv[1].split("/")[1], sys.argv[2]):
        print(",latest", end="")
