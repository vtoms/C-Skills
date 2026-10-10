import json, pathlib

CACHE = pathlib.Path(__file__).with_name("users.cache.json")


def load_cached_users():
    # Written by an older deploy with the old serializer; read back as-is.
    return [json.loads(line) for line in CACHE.read_text().splitlines()]
