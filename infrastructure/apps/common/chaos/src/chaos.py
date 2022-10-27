# Copyright 2022 Amazon.com and its affiliates; all rights reserved.
# This file is Amazon Web Services Content and may not be duplicated or distributed without permission.

from disable_vpc_endpoint import *
from enable_vpc_endpoint import *
from dummy import *

import logging


def invoke(event, context):
    logging.basicConfig(format='%(asctime)s %(message)s', level=logging.INFO)

    function = event["FUNCTION"]

    if function == "disable_vpc_endpoint":
        return disable_vpc_endpoint(event, context)
    elif function == "enable_vpc_endpoint":
        return enable_vpc_endpoint(event, context)
    else:
        dummy(event, context)


if __name__ == "__main__":
    event = dict()
    event["FUNCTION"] = "dummy"
    invoke(event, None)