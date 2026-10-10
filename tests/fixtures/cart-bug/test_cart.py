from cart import checkout


def test_single_checkout():
    assert checkout(["apple", "milk"]) == {"items": ["apple", "milk"], "total": 1.6}
