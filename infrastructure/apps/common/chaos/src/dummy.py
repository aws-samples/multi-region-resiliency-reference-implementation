# Copyright 2022 Amazon.com and its affiliates; all rights reserved.
# This file is Amazon Web Services Content and may not be duplicated or distributed without permission.


def dummy(event, context):
    print("dummy")


if __name__ == "__main__":
    event = dict()
    dummy(event, None)