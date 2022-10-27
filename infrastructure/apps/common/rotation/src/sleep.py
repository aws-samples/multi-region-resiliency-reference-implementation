
from datetime import datetime
import time


def sleep(event, context):

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " sleep Invoked")
    duration = event['DURATION']
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " Duration: " + str(duration))

    time.sleep(duration)


if __name__ == "__main__":
    event = dict()
    event["DURATION"] = 5
    sleep(event, None)