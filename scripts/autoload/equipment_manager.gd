extends Node

signal equipment_changed

const EQUIPMENT_SLOTS := ["weapon", "armor", "boots", "accessory"]
const MAX_ENHANCEMENT_LEVEL := 5

# Biaya material per level peningkatan. Level yang dimaksud adalah level tujuan.
const ENHANCEMENT_COSTS := {
    "weapon": {"iron_ingot": 1, "blue_crystal": 1},
    "armor": {"iron_ingot": 1, "stone": 2},
    "boots": {"wood": 2, "blue_crystal": 1},
    "accessory": {"purple_crystal": 1, "ancient_shard": 1}
}

var equipped: Dictionary = {
    "weapon": "",
    "armor": "",
    "boots": "",
    "accessory": ""
}
# Disimpan berdasarkan item ID agar peningkatan tetap melekat pada item.
var enhancement_levels: Dictionary = {}

var _layer: CanvasLayer
var _panel: PanelContainer
var _rows: VBoxContainer

func _ready() -> void:
    _build_enhancement_ui()

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_U:
        toggle_enhancement_ui()
        get_viewport().set_input_as_handled()

func get_item_equipment_data(item_id: String) -> Dictionary:
    var data: Dictionary = InventoryManager.item_catalog.get(item_id, {})
    if not data.has("equipment_slot"):
        return {}
    var slot := str(data.get("equipment_slot", ""))
    var level := get_enhancement_level(item_id)
    var bonus := _get_enhancement_bonus(slot, level)
    return {
        "slot": slot,
        "attack": int(data.get("attack", 0)) + int(bonus.get("attack", 0)),
        "defense": int(data.get("defense", 0)) + int(bonus.get("defense", 0)),
        "max_health": int(data.get("max_health", 0)) + int(bonus.get("max_health", 0)),
        "move_speed": float(data.get("move_speed", 0.0)) + float(bonus.get("move_speed", 0.0)),
        "enhancement_level": level
    }

func _get_enhancement_bonus(slot: String, level: int) -> Dictionary:
    var safe_level := clampi(level, 0, MAX_ENHANCEMENT_LEVEL)
    match slot:
        "weapon":
            return {"attack": safe_level * 2}
        "armor":
            return {"defense": safe_level, "max_health": safe_level * 5}
        "boots":
            return {"move_speed": safe_level * 2.0}
        "accessory":
            return {"attack": safe_level, "defense": safe_level, "max_health": safe_level * 2}
    return {}

func get_enhancement_level(item_id: String) -> int:
    return clampi(int(enhancement_levels.get(item_id, 0)), 0, MAX_ENHANCEMENT_LEVEL)

func get_enhancement_cost(slot: String) -> Dictionary:
    var base_cost: Dictionary = ENHANCEMENT_COSTS.get(slot, {})
    var current_level := 0
    var item_id := str(equipped.get(slot, ""))
    if item_id != "":
        current_level = get_enhancement_level(item_id)
    var next_level := current_level + 1
    var result: Dictionary = {}
    for material_id in base_cost:
        result[str(material_id)] = int(base_cost[material_id]) * next_level
    return result

func get_missing_enhancement_materials(slot: String) -> Dictionary:
    var missing: Dictionary = {}
    var cost := get_enhancement_cost(slot)
    for material_id in cost:
        var required := int(cost[material_id])
        var owned := InventoryManager.get_amount(str(material_id))
        if owned < required:
            missing[str(material_id)] = required - owned
    return missing

func can_enhance_slot(slot: String) -> bool:
    if not EQUIPMENT_SLOTS.has(slot):
        return false
    var item_id := str(equipped.get(slot, ""))
    if item_id == "" or get_item_equipment_data(item_id).is_empty():
        return false
    if get_enhancement_level(item_id) >= MAX_ENHANCEMENT_LEVEL:
        return false
    return get_missing_enhancement_materials(slot).is_empty()

func enhance_equipped(slot: String) -> Dictionary:
    if not EQUIPMENT_SLOTS.has(slot):
        return {"ok": false, "message": "Slot perlengkapan tidak valid."}
    var item_id := str(equipped.get(slot, ""))
    if item_id == "":
        return {"ok": false, "message": "Tidak ada perlengkapan pada slot ini."}
    if get_item_equipment_data(item_id).is_empty():
        return {"ok": false, "message": "Item yang dipakai bukan perlengkapan yang valid."}
    var current_level := get_enhancement_level(item_id)
    if current_level >= MAX_ENHANCEMENT_LEVEL:
        return {"ok": false, "message": "Perlengkapan sudah mencapai level maksimum."}

    var missing := get_missing_enhancement_materials(slot)
    if not missing.is_empty():
        return {"ok": false, "message": "Material kurang: %s." % _format_materials(missing)}

    var cost := get_enhancement_cost(slot)
    var removed: Dictionary = {}
    for material_id in cost:
        var amount := int(cost[material_id])
        if not InventoryManager.remove_item(str(material_id), amount):
            for rollback_id in removed:
                InventoryManager.add_item(str(rollback_id), int(removed[rollback_id]))
            return {"ok": false, "message": "Gagal mengambil material. Peningkatan dibatalkan."}
        removed[str(material_id)] = amount

    enhancement_levels[item_id] = current_level + 1
    equipment_changed.emit()
    SaveManager.save_game()
    _refresh_enhancement_ui()
    var message := "%s berhasil ditingkatkan ke +%d." % [
        InventoryManager.get_item_name(item_id), current_level + 1
    ]
    GameManager.notification_requested.emit(message)
    return {"ok": true, "message": message}

func _format_materials(materials: Dictionary) -> String:
    var parts: PackedStringArray = []
    for material_id in materials:
        parts.append("%s x%d" % [
            InventoryManager.get_item_name(str(material_id)),
            int(materials[material_id])
        ])
    return ", ".join(parts)

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
    _refresh_enhancement_ui()
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
    _refresh_enhancement_ui()
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
        var level_text := " +%d" % get_enhancement_level(item_id) if item_id != "" and get_enhancement_level(item_id) > 0 else ""
        parts.append("%s: %s%s" % [slot.capitalize(), label, level_text])
    var bonuses := "Bonus: ATK +%d | DEF +%d | HP +%d | Kecepatan +%d" % [
        int(get_total_stat("attack")),
        int(get_total_stat("defense")),
        int(get_total_stat("max_health")),
        int(get_total_stat("move_speed"))
    ]
    return " | ".join(parts) + "\n" + bonuses

func get_save_data() -> Dictionary:
    return {
        "equipped": equipped.duplicate(true),
        "enhancement_levels": enhancement_levels.duplicate(true)
    }

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

    enhancement_levels.clear()
    var raw_levels = data.get("enhancement_levels", {})
    if typeof(raw_levels) == TYPE_DICTIONARY:
        for item_id in raw_levels:
            if InventoryManager.item_catalog.has(str(item_id)):
                enhancement_levels[str(item_id)] = clampi(int(raw_levels[item_id]), 0, MAX_ENHANCEMENT_LEVEL)
    equipment_changed.emit()
    _refresh_enhancement_ui()

func toggle_enhancement_ui(force_state: Variant = null) -> void:
    if not is_instance_valid(_panel):
        return
    _panel.visible = not _panel.visible if force_state == null else bool(force_state)
    if _panel.visible:
        _refresh_enhancement_ui()

func _build_enhancement_ui() -> void:
    _layer = CanvasLayer.new()
    _layer.name = "EquipmentEnhancementCanvas"
    add_child(_layer)

    _panel = PanelContainer.new()
    _panel.name = "EquipmentEnhancementPanel"
    _panel.position = Vector2(220, 65)
    _panel.custom_minimum_size = Vector2(520, 410)
    _panel.visible = false
    _layer.add_child(_panel)

    var outer := VBoxContainer.new()
    _panel.add_child(outer)

    var header := HBoxContainer.new()
    outer.add_child(header)
    var title := Label.new()
    title.text = "ENHANCEMENT & ENCHANTMENT"
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)

    var close_button := Button.new()
    close_button.text = "TUTUP"
    close_button.pressed.connect(toggle_enhancement_ui.bind(false))
    header.add_child(close_button)

    var hint := Label.new()
    hint.text = "Tekan U untuk membuka. Peningkatan pasti berhasil dan maksimum +5."
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    outer.add_child(hint)

    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    outer.add_child(scroll)

    _rows = VBoxContainer.new()
    _rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(_rows)
    _refresh_enhancement_ui()

func _refresh_enhancement_ui() -> void:
    if not is_instance_valid(_rows):
        return
    for child in _rows.get_children():
        _rows.remove_child(child)
        child.queue_free()

    for slot in EQUIPMENT_SLOTS:
        var item_id := str(equipped.get(slot, ""))
        var row := VBoxContainer.new()
        _rows.add_child(row)

        var label := Label.new()
        if item_id == "":
            label.text = "%s — belum ada perlengkapan" % slot.capitalize()
            row.add_child(label)
            _rows.add_child(HSeparator.new())
            continue

        var level := get_enhancement_level(item_id)
        label.text = "%s — %s (+%d/%d)" % [
            slot.capitalize(),
            InventoryManager.get_item_name(item_id),
            level,
            MAX_ENHANCEMENT_LEVEL
        ]
        row.add_child(label)

        var bonus := _get_enhancement_bonus(slot, level)
        var bonus_parts: PackedStringArray = []
        for stat_name in bonus:
            if float(bonus[stat_name]) != 0.0:
                bonus_parts.append("%s +%s" % [stat_name.to_upper(), str(bonus[stat_name])])
        var bonus_label := Label.new()
        bonus_label.text = "Bonus peningkatan: %s" % (", ".join(bonus_parts) if not bonus_parts.is_empty() else "Belum ada")
        row.add_child(bonus_label)

        var cost_label := Label.new()
        if level >= MAX_ENHANCEMENT_LEVEL:
            cost_label.text = "Level maksimum tercapai."
        else:
            var cost := get_enhancement_cost(slot)
            var owned_parts: PackedStringArray = []
            for material_id in cost:
                owned_parts.append("%s %d/%d" % [
                    InventoryManager.get_item_name(str(material_id)),
                    InventoryManager.get_amount(str(material_id)),
                    int(cost[material_id])
                ])
            cost_label.text = "Biaya level berikutnya: %s" % ", ".join(owned_parts)
        cost_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        row.add_child(cost_label)

        var enhance_button := Button.new()
        enhance_button.text = "TINGKATKAN KE +%d" % (level + 1)
        enhance_button.disabled = level >= MAX_ENHANCEMENT_LEVEL or not can_enhance_slot(slot)
        enhance_button.pressed.connect(_enhance_from_ui.bind(slot))
        row.add_child(enhance_button)
        _rows.add_child(HSeparator.new())

func _enhance_from_ui(slot: String) -> void:
    var result := enhance_equipped(slot)
    if not bool(result.get("ok", false)):
        GameManager.notification_requested.emit(str(result.get("message", "Peningkatan gagal.")))
    _refresh_enhancement_ui()
