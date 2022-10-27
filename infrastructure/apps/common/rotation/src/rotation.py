
from dummy import *
from get_regions import *
from detach_and_promote_aurora import *
from rotate_aurora_global_database import *
from wait_for_aurora_to_be_available import *
from update_database_secret import *
from switch_off_primary_controls import *
from switch_on_secondary_controls import *
from update_arc_control import *
from wait_for_aurora_to_replicate import *
from wait_for_dynamodb_to_replicate import *
from wait_for_kinesis_streams import *
from wait_for_mq_to_drain import *
from restart_ecs_service import *
from reconciliation import *
from damage_maker import *
from sleep import *
from clear_databases import *
from get_app_state import *
import logging


def invoke(event, context):
    logging.basicConfig(format='%(asctime)s %(message)s', level=logging.INFO)

    function = event["FUNCTION"]

    if function == "get_regions":
        return get_regions(event, context)
    elif function == "detach_and_promote_aurora":
        return detach_and_promote_aurora(event, context)
    elif function == "rotate_aurora_global_database":
        return rotate_aurora_global_database(event, context)
    elif function == "wait_for_aurora_to_be_available":
        wait_for_aurora_to_be_available(event, context)
    elif function == "update_database_secret":
        update_database_secret(event, context)
    elif function == "switch_off_primary_controls":
        switch_off_primary_controls(event, context)
    elif function == "switch_on_secondary_controls":
        switch_on_secondary_controls(event, context)
    elif function == "update_arc_control":
        update_arc_control(event, context)
    elif function == "wait_for_aurora_to_replicate":
        wait_for_aurora_to_replicate(event, context)
    elif function == "wait_for_dynamodb_to_replicate":
        wait_for_dynamodb_to_replicate(event, context)
    elif function == "wait_for_kinesis_streams":
        wait_for_kinesis_streams(event, context)
    elif function == "wait_for_mq_to_drain":
        wait_for_mq_to_drain(event, context)
    elif function == "restart_ecs_service":
        restart_ecs_service(event, context)
    elif function == "reconciliation":
        execute_reconciliation(event, context)
    elif function == "damage_maker":
        damage_maker(event, context)
    elif function == "sleep":
        sleep(event, context)
    elif function == "clear_databases":
        clear_databases(event, context)
    elif function == "get_app_state":
        get_app_state(event, context)
    elif function == "compare_app_states":
        compare_app_states(event, context)
    else:
        dummy(event, context)


if __name__ == "__main__":
    event = dict()
    event["FUNCTION"] = "dummy"
    invoke(event, None)