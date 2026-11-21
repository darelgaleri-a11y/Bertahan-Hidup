extends Node

signal loot_changed

# Loot yang gagal masuk inventory disimpan di peti loot pemain.
var pending_loot: Dictionary = {}

func store_loot(item_id: String, amount: int) -> void:
    if amount <= 0 or not InventoryManager.item_catalog.has(item_id):
        return
    pending_loot[item_id] = int(pending_loot.get(item_id, 0)) + amount
    loot_changed.emit()
    GameManager.notification_requested.emit(
        "%s x%d disimpan di Peti Loot karena inventory penuh." % [
            InventoryManager.get_item_name(item_id), amount
        ]
    )

func claim_pending_loot() -> int:
    var claimed := 0
    var item_ids: Array = pending_loot.keys()
    item_ids.sort()
    for item_id_value in item_ids:
        var item_id := str(item_id_value)
        while int(pending_loot.get(item_id, 0)) > 0:
            if not InventoryManager.add_item(item_id, 1):
                break
            pending_loot[item_id] = int(pending_loot[item_id]) - 1
            claimed += 1
        if int(pending_loot.get(item_id, 0)) <= 0:
            pending_loot.erase(item_id)
    loot_changed.emit()
    return claimed

func get_pending_count() -> int:
    var total := 0
    for amount in pending_loot.values():
        total += maxi(0, int(amount))
    return total

func load_save_data(data: Dictionary) -> void:
    pending_loot.clear()
    for key in data.keys():
        var item_id := str(key)
        var amount := maxi(0, int(data[key]))
        if amount > 0 and InventoryManager.item_catalog.has(item_id):
            pending_loot[item_id] = amount
    loot_changed.emit()

func get_save_data() -> Dictionary:
    return pending_loot.duplicate(true)
