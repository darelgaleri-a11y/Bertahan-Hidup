extends Node

signal inventory_changed
const SLOT_LIMIT := 30
var items: Dictionary = {"seed_basic": 1, "feed_basic": 3}

func add_item(item_id: String, amount: int = 1) -> bool:
    if amount <= 0:
        return false
    items[item_id] = int(items.get(item_id, 0)) + amount
    inventory_changed.emit()
    return true

func remove_item(item_id: String, amount: int = 1) -> bool:
    if amount <= 0 or int(items.get(item_id, 0)) < amount:
        return false
    items[item_id] = int(items[item_id]) - amount
    if items[item_id] <= 0:
        items.erase(item_id)
    inventory_changed.emit()
    return true

func get_amount(item_id: String) -> int:
    return int(items.get(item_id, 0))
