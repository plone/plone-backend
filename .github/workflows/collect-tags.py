#!/bin/env python3
"""Given a directory containing a Makefile to build Plone images,
collect all the tags in the images and print them as JSON.
"""
import os
import sys
import re


def print_tags(path):
    makefile_contents = open(os.path.join(path, "Makefile")).read()
    python_version = os.environ.get("PYTHON_VERSION")
    image_tag = get_variable("IMAGE_TAG", makefile_contents)
    print(f'plone-backend:{image_tag}-python{python_version}')


def get_variable(variable_name, makefile_contents):
    """Naively extract a variable definition from a string representing a Makefile"""
    return re.search(rf"^{variable_name}=(.*)", makefile_contents, re.MULTILINE).groups()[0]


if __name__ == '__main__':
    print_tags(sys.argv[1])
