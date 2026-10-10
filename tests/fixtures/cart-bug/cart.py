"""Tiny shopping-cart service used as a debugging fixture."""

PRICES = {"apple": 0.50, "bread": 2.25, "milk": 1.10}


def add_items(names, cart=[]):
    for name in names:
        if name not in PRICES:
            raise KeyError(f"unknown item: {name}")
        cart.append(name)
    return cart


def checkout(names):
    cart = add_items(names)
    total = round(sum(PRICES[n] for n in cart), 2)
    return {"items": list(cart), "total": total}
