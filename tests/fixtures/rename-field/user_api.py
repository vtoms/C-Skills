import json


def serialize_user(user):
    # PROPOSED CHANGE (diff under review): "email" key renamed to "email_address"
    return json.dumps({"id": user["id"], "email_address": user["email"]})
