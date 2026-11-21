extends Node

signal equipment_changed

const EQUIPMENT_SLOTS := ["weapon", "armor", "boots", "accessory"]
var equipped: Dictionary = {
    "weapon": "",
    "armor": "",
    "boots": "",
    "accessory": ""
}

func get_item_equipment_data(item_id: String) -> Dictionary:
    var data: Dictionary = InventoryManager.item_catalog.get(item_id, {})
    if not data.has("equipment_slot"):
        return {}
    return {
        "slot": str(data.get("equipment_slot", "")),
        "attack": int(data.get("attack", 0)),
        "defense": int(data.get("defense", 0)),
        "max_health": int(data.get("max_health", 0)),
        "move_speed": float(data.get("move_speed", 0.0))
    }

func equip_item(item_id: String) -> Dictionary:
    var data := get_item_equipment_data(item_id)
    if data.is_empty():
        return {"ok": false, "message": "Item ini bukan perlengkapan."}
    var slot := str(data.get("slot", ""))
    if not EQUIPMENT_SLOTS.has(slot):
        return {"ok": false, "message": "Slot perlengkapan tidak valid."}
    if InventoryManager.get_amount(item_id) <= 0:
        return {"ok": false, "message": "Perlengkapan tidak ada di inventory."}
    if str(equipped.get(slot, "")) == item_id:
        return {"ok": false, "message": "Perlengkapan ini sudah dipakai."}

    var previous_item := str(equipped.get(slot, ""))
    if previous_item != "":
        var current_amount := InventoryManager.get_amount(item_id)
        var frees_slot := current_amount == 1
        if not InventoryManager.can_add_item(previous_item, 1) and not (frees_slot and InventoryManager.get_used_slots() >= InventoryManager.SLOT_LIMIT):
            return {"ok": false, "message": "Inventory penuh. Kosongkan satu slot sebelum mengganti perlengkapan."}

    if not InventoryManager.remove_item(item_id, 1):
        return {"ok": false, "message": "Gagal mengambil perlengkapan dari inventory."}

    if previous_item != "" and not InventoryManager.add_item(previous_item, 1):
        InventoryManager.add_item(item_id, 1)
        return {"ok": false, "message": "Penggantian gagal. Perlengkapan lama tetap dipakai."}

    equipped[slot] = item_id
    equipment_changed.emit()
    return {"ok": true, "message": "%s berhasil dipakai." % InventoryManager.get_item_name(item_id)}

func unequip_slot(slot: String) -> Dictionary:
    if not EQUIPMENT_SLOTS.has(slot):
        return {"ok": false, "message": "Slot perlengkapan tidak valid."}
    var item_id := str(equipped.get(slot, ""))
    if item_id == "":
        return {"ok": false, "message": "Slot ini sedang kosong."}
    if not InventoryManager.add_item(item_id, 1):
        return {"ok": false, "message": "Inventory penuh. Tidak bisa melepas perlengkapan."}
    equipped[slot] = ""
    equipment_changed.emit()
    return {"ok": true, "message": "%s dilepas." % InventoryManager.get_item_name(item_id)}

func get_total_stat(stat_name: String) -> float:
    var total := 0.0
    for slot in EQUIPMENT_SLOTS:
        var item_id := str(equipped.get(slot, ""))
        if item_id == "":
            continue
        var data := get_item_equipment_data(item_id)
        total += float(data.get(stat_name, 0.0))
    return total

func get_equipment_summary() -> String:
    var parts := PackedStringArray()
    for slot in EQUIPMENT_SLOTS:
        var item_id := str(equipped.get(slot, ""))
        var label := InventoryManager.get_item_name(item_id) if item_id != "" else "Kosong"
        parts.append("%s: %s" % [slot.capitalize(), label])
    var bonuses := "Bonus: ATK +%d | DEF +%d | HP +%d | Kecepatan +%d" % [
        int(get_total_stat("attack")),
        int(get_total_stat("defense")),
        int(get_total_stat("max_health")),
        int(get_total_stat("move_speed"))
    ]
    return " | ".join(parts) + "\\n" + bonuses

func get_save_data() -> Dictionary:
    return {"equipped": equipped.duplicate(true)}

func load_save_data(data: Dictionary) -> void:
    var raw_equipped = data.get("equipped", {})
    var clean: Dictionary = {}
    for slot in EQUIPMENT_SLOTS:
        var item_id := str(raw_equipped.get(slot, "")) if typeof(raw_equipped) == TYPE_DICTIONARY else ""
        var item_data := get_item_equipment_data(item_id) if item_id != "" else {}
        if not item_data.is_empty() and str(item_data.get("slot", "")) == slot:
            clean[slot] = item_id
        else:
            clean[slot] = ""
    equipped = clean
    equipment_changed.emit()
