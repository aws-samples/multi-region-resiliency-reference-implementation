# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import setuptools

with open("src/README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="reconciliation-app",
    version="0.1.0",
    long_description_content_type='text/makrdown',
    description="An application to preform reconciliation for trading app",
    author="author",
    packages=['reconciliation-app'],
    install_requires=[
        "packaging==21.3",
        "bumpversion",
        "requests",
        "boto3",
        "pyopenssl"
    ],

    python_requires=">=3.9",
)
