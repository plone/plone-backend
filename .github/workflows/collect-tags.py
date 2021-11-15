#!/bin/env python3
"""Given a directory containing a Makefile to build Plone images,
collect all the tags in the images and print them as JSON.
"""
import os
import sys
import re
from is_latest import is_latest, is_latest_supported_python


def print_tags(path):
    makefile_contents = open(os.path.join(path, "Makefile")).read()
    python_version = os.environ.get("PYTHON_VERSION")
    image_tag = get_variable("IMAGE_TAG", makefile_contents)
    plone_version = path.split("/")[1]
    print(f'plone/plone-backend:{image_tag}-python{python_version}', end="")
    if is_latest_supported_python(plone_version, python_version):
        print(f",plone/plone-backend:{image_tag}", end="")
    if is_latest(plone_version, python_version):
        print(",plone/plone-backend:latest", end="")
    print()

def get_variable(variable_name, makefile_contents):
    """Naively extract a variable definition from a string representing a Makefile"""
    return re.search(rf"^{variable_name}=(.*)", makefile_contents, re.MULTILINE).groups()[0]


if __name__ == '__main__':
    print_tags(sys.argv[1])
