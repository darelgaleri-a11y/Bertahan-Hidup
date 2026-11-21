extends Node

signal inventory_changed

const SLOT_LIMIT := 30
const DEFAULT_STACK_LIMIT := 99
const CATALOG_PATH := "res://data/item_catalog.json"

var items: Dictionary = {"seed_basic": 1, "feed_basic": 3}
var item_catalog: Dictionary = {}

func _ready() -> void:
    _load_catalog()
    sanitize_inventory()

func _load_catalog() -> void:
    if not FileAccess.file_exists(CATALOG_PATH):
        push_error("Katalog item tidak ditemukan: " + CATALOG_PATH)
        return
    var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
    if file == null:
        push_error("Katalog item tidak dapat dibuka.")
        return
    var parsed = JSON.parse_string(file.get_as_text())
    file.close()
    if typeof(parsed) == TYPE_DICTIONARY:
        item_catalog = parsed
    else:
        push_error("Format katalog item tidak valid.")

func sanitize_inventory() -> void:
    var clean: Dictionary = {}
    for key in items.keys():
        var item_id := str(key)
        var amount := maxi(0, int(items[key]))
        if amount > 0 and item_catalog.has(item_id):
            clean[item_id] = mini(amount, get_stack_limit(item_id))
    items = clean

func get_stack_limit(item_id: String) -> int:
    var data: Dictionary = item_catalog.get(item_id, {})
    return maxi(1, int(data.get("stack_limit", DEFAULT_STACK_LIMIT)))

func get_item_name(item_id: String) -> String:
    var data: Dictionary = item_catalog.get(item_id, {})
    return str(data.get("name", item_id))

func get_sell_price(item_id: String) -> int:
    var data: Dictionary = item_catalog.get(item_id, {})
    return maxi(0, int(data.get("sell_price", 0)))

func get_used_slots() -> int:
    return items.size()

func can_add_item(item_id: String, amount: int = 1) -> bool:
    if amount <= 0 or not item_catalog.has(item_id):
        return false
    var current := int(items.get(item_id, 0))
    return current + amount <= get_stack_limit(item_id) and (current > 0 or items.size() < SLOT_LIMIT)

func add_item(item_id: String, amount: int = 1) -> bool:
    if amount <= 0 or not item_catalog.has(item_id):
        return false
    var current := int(items.get(item_id, 0))
    if current + amount > get_stack_limit(item_id):
        return false
    if current == 0 and items.size() >= SLOT_LIMIT:
        return false
    items[item_id] = current + amount
    inventory_changed.emit()
    return true

func remove_item(item_id: String, amount: int = 1) -> bool:
    if amount <= 0 or int(items.get(item_id, 0)) < amount:
        return false
    var remaining := int(items[item_id]) - amount
    if remaining <= 0:
        items.erase(item_id)
    else:
        items[item_id] = remaining
    inventory_changed.emit()
    return true

func sell_item(item_id: String, amount: int = 1) -> bool:
    var price := get_sell_price(item_id)
    if price <= 0 or amount <= 0 or not remove_item(item_id, amount):
        return false
    GameManager.add_money(price * amount)
    return true

func get_amount(item_id: String) -> int:
    return int(items.get(item_id, 0))
