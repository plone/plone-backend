#!/bin/env python3
"""Print the string ",latest" if the version given
as argument is the latest version, otherwise print nothing.
Example invocation:

    is_latest.py 5.2/5.2.6 39
"""
import sys
import collect_matrix
from distutils.version import StrictVersion


python_versions = {
    # Map the python versions as used in tag names, Makefiles etc
    # to lexycographically sortable versions
    "36": "036",
    "37": "037",
    "38": "038",
    "39": "039",
    "310": "310",
    "311": "311",
}

def sortable_pyv(version):
    return python_versions.get(version, version)


def get_available_versions():
    available_versions = []
    for el in collect_matrix.get_matrix():
        try:
            version = StrictVersion(el['plone-version'].split("/")[1])
        except ValueError:
            continue
        if not version.prerelease:
            available_versions.append((version, sortable_pyv(el['python-version'])))
    return sorted(available_versions)


def is_latest(plone_version_to_examine: str, python_version_to_examine: str):
    available_versions = get_available_versions()
    latest_plone_version = str(available_versions[-1][0])
    latest_python_version = str(available_versions[-1][1])
    if latest_plone_version == plone_version_to_examine and sortable_pyv(python_version_to_examine) == str(latest_python_version):
        return True


def is_latest_supported_python(plone_version, python_version):
    available_versions = []
    for el in collect_matrix.get_matrix():
        if el['plone-version'].split("/")[1] == plone_version:
            available_versions.append(sortable_pyv(el['python-version']))
    available_versions.sort()
    return sortable_pyv(python_version) == available_versions[-1]


if __name__ == '__main__':
    if is_latest(sys.argv[1].split("/")[1], sys.argv[2]):
        print(",latest", end="")
