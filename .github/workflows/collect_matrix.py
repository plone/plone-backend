#!/bin/env python3
"""
Inspect directory structure to determine a matrix to be used
for Github actions builds.
"""
import os
import json


def directories_on_level_2():
    """Return a list including all directories two levels deep
    in the current hierarchy,
    """
    for directory in os.listdir("."):
        if not directory.startswith(".") and os.path.isdir(directory):
            for subdirectory in os.listdir(directory):
                path = os.path.join(directory, subdirectory)
                if os.path.isdir(path):
                    yield path


def filter_out_directories_starting_with_dot(directories):
    """Return a list of directories without those starting with a dot"""
    return [directory for directory in directories if not directory.startswith(".")]


def get_matrix():
    """Return a list of dictionaries suitable for use in an action matrix.include"""
    for directory in directories_on_level_2():
        for file in os.listdir(directory):
            if file.startswith("Dockerfile."):
                yield {
                    "python-version": file[len("Dockerfile.python") :],
                    "plone-version": directory,
                }


if __name__ == "__main__":
    print(json.dumps(list(get_matrix())))
