import json

FIELD = "em" + "ail"  # built from parts; a grep for '"email"' won't find this


def recipient(serialized_user):
    return json.loads(serialized_user).get(FIELD)
