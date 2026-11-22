extends Node
## Mengelola daya tahan, perbaikan, dan peningkatan alat gathering.
## Kondisi alat disimpan terpisah dari jumlah item agar kompatibel dengan inventory stack lama.

signal tool_state_changed(item_id: String)

const TOOL_IDS := ["wooden_axe", "wooden_pickaxe", "iron_axe", "iron_pickaxe"]
const REPAIR_COSTS := {
    "wooden_axe": {"wood": 2},
    "wooden_pickaxe": {"stone": 2},
    "iron_axe": {"iron_ingot": 2, "wood": 1},
    "iron_pickaxe": {"iron_ingot": 2, "stone": 2}
}

var tool_states: Dictionary = {}
var _layer: CanvasLayer
var _panel: PanelContainer
var _list: VBoxContainer

func _ready() -> void:
    _build_ui()
    _ensure_owned_tool_states()

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_T:
        toggle_ui()
        get_viewport().set_input_as_handled()

func get_max_durability(item_id: String) -> int:
    var data: Dictionary = InventoryManager.item_catalog.get(item_id, {})
    return maxi(1, int(data.get("max_durability", 100)))

func _ensure_tool_state(item_id: String) -> void:
    if not TOOL_IDS.has(item_id):
        return
    var maximum := get_max_durability(item_id)
    if not tool_states.has(item_id) or typeof(tool_states[item_id]) != TYPE_DICTIONARY:
        tool_states[item_id] = {"current": maximum, "max": maximum}
        return
    var state: Dictionary = tool_states[item_id]
    state["max"] = maximum
    state["current"] = clampi(int(state.get("current", maximum)), 0, maximum)
    tool_states[item_id] = state

func _ensure_owned_tool_states() -> void:
    for item_id in TOOL_IDS:
        if InventoryManager.get_amount(item_id) > 0:
            _ensure_tool_state(item_id)

func get_durability(item_id: String) -> int:
    _ensure_tool_state(item_id)
    var state: Dictionary = tool_states.get(item_id, {})
    return int(state.get("current", 0))

func get_durability_ratio(item_id: String) -> float:
    var maximum := get_max_durability(item_id)
    return float(get_durability(item_id)) / float(maximum)

func get_best_tool(tool_type: String) -> Dictionary:
    var candidates: Array[String] = []
    if tool_type == "axe":
        candidates = ["wooden_axe", "iron_axe"]
    elif tool_type == "pickaxe":
        candidates = ["wooden_pickaxe", "iron_pickaxe"]
    else:
        return {}
    var best: Dictionary = {}
    for item_id in candidates:
        if InventoryManager.get_amount(item_id) <= 0:
            continue
        _ensure_tool_state(item_id)
        if get_durability(item_id) <= 0:
            continue
        var item_data: Dictionary = InventoryManager.item_catalog.get(item_id, {})
        var power := int(item_data.get("tool_power", 1))
        if best.is_empty() or power > int(best.get("tool_power", 0)):
            best = {
                "item_id": item_id,
                "name": InventoryManager.get_item_name(item_id),
                "tool_type": tool_type,
                "tool_power": power,
                "durability": get_durability(item_id),
                "max_durability": get_max_durability(item_id)
            }
    return best

func has_tool(tool_type: String) -> bool:
    return not get_best_tool(tool_type).is_empty()

func get_gather_bonus(tool_type: String) -> int:
    var tool := get_best_tool(tool_type)
    if tool.is_empty():
        return 0
    return maxi(0, int(tool.get("tool_power", 1)) - 1)

func get_tool_name(tool_type: String) -> String:
    var tool := get_best_tool(tool_type)
    return str(tool.get("name", "")) if not tool.is_empty() else ""

func use_tool(item_id: String, wear: int = 1) -> bool:
    if wear <= 0 or InventoryManager.get_amount(item_id) <= 0 or not TOOL_IDS.has(item_id):
        return false
    _ensure_tool_state(item_id)
    var state: Dictionary = tool_states[item_id]
    var before := int(state.get("current", 0))
    if before <= 0:
        return false
    state["current"] = maxi(0, before - wear)
    tool_states[item_id] = state
    tool_state_changed.emit(item_id)
    if int(state["current"]) <= 0:
        GameManager.notification_requested.emit("%s telah rusak. Perbaiki sebelum digunakan lagi." % InventoryManager.get_item_name(item_id))
    else:
        GameManager.notification_requested.emit("%s: daya tahan %d/%d." % [
            InventoryManager.get_item_name(item_id), int(state["current"]), int(state["max"])
        ])
    SaveManager.save_game()
    _refresh_ui()
    return true

func get_missing_repair_materials(item_id: String) -> Dictionary:
    var missing: Dictionary = {}
    var costs: Dictionary = REPAIR_COSTS.get(item_id, {})
    for material_id in costs:
        var needed := int(costs[material_id])
        var owned := InventoryManager.get_amount(str(material_id))
        if owned < needed:
            missing[str(material_id)] = needed - owned
    return missing

func repair_tool(item_id: String) -> Dictionary:
    if not TOOL_IDS.has(item_id) or InventoryManager.get_amount(item_id) <= 0:
        return {"ok": false, "message": "Alat tidak ditemukan di inventory."}
    _ensure_tool_state(item_id)
    if get_durability(item_id) >= get_max_durability(item_id):
        return {"ok": false, "message": "Daya tahan alat masih penuh."}
    var missing := get_missing_repair_materials(item_id)
    if not missing.is_empty():
        return {"ok": false, "message": "Bahan perbaikan kurang: %s." % _format_materials(missing)}
    var costs: Dictionary = REPAIR_COSTS.get(item_id, {})
    for material_id in costs:
        if not InventoryManager.remove_item(str(material_id), int(costs[material_id])):
            return {"ok": false, "message": "Gagal mengambil bahan perbaikan."}
    var state: Dictionary = tool_states[item_id]
    state["current"] = get_max_durability(item_id)
    tool_states[item_id] = state
    tool_state_changed.emit(item_id)
    SaveManager.save_game()
    _refresh_ui()
    GameManager.notification_requested.emit("%s berhasil diperbaiki." % InventoryManager.get_item_name(item_id))
    return {"ok": true, "message": "Perbaikan berhasil."}

func _format_materials(materials: Dictionary) -> String:
    var parts: PackedStringArray = []
    for material_id in materials:
        parts.append("%s x%d" % [InventoryManager.get_item_name(str(material_id)), int(materials[material_id])])
    return ", ".join(parts)

func get_save_data() -> Dictionary:
    var result: Dictionary = {}
    for item_id in tool_states:
        var state: Dictionary = tool_states[item_id]
        result[str(item_id)] = {
            "current": int(state.get("current", 0)),
            "max": get_max_durability(str(item_id))
        }
    return result

func load_save_data(data: Dictionary) -> void:
    tool_states.clear()
    for item_id in TOOL_IDS:
        if not data.has(item_id) or typeof(data[item_id]) != TYPE_DICTIONARY:
            continue
        var raw: Dictionary = data[item_id]
        var maximum := get_max_durability(item_id)
        tool_states[item_id] = {
            "current": clampi(int(raw.get("current", maximum)), 0, maximum),
            "max": maximum
        }
    _ensure_owned_tool_states()
    _refresh_ui()

func _build_ui() -> void:
    _layer = CanvasLayer.new()
    _layer.name = "ToolDurabilityCanvas"
    add_child(_layer)
    _panel = PanelContainer.new()
    _panel.name = "ToolDurabilityPanel"
    _panel.position = Vector2(250, 90)
    _panel.custom_minimum_size = Vector2(460, 330)
    _panel.visible = false
    _layer.add_child(_panel)
    var outer := VBoxContainer.new()
    _panel.add_child(outer)
    var header := HBoxContainer.new()
    outer.add_child(header)
    var title := Label.new()
    title.text = "KONDISI & PERBAIKAN ALAT"
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)
    var close_button := Button.new()
    close_button.text = "TUTUP"
    close_button.pressed.connect(toggle_ui.bind(false))
    header.add_child(close_button)
    var hint := Label.new()
    hint.text = "Tekan T untuk membuka. Setiap gathering mengurangi 1 daya tahan."
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    outer.add_child(hint)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    outer.add_child(scroll)
    _list = VBoxContainer.new()
    _list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(_list)
    _refresh_ui()

func toggle_ui(force_state: Variant = null) -> void:
    if not is_instance_valid(_panel):
        return
    _panel.visible = not _panel.visible if force_state == null else bool(force_state)
    if _panel.visible:
        _refresh_ui()

func _refresh_ui() -> void:
    if not is_instance_valid(_list):
        return
    for child in _list.get_children():
        _list.remove_child(child)
        child.queue_free()
    var found := false
    for item_id in TOOL_IDS:
        if InventoryManager.get_amount(item_id) <= 0:
            continue
        found = true
        _ensure_tool_state(item_id)
        var current := get_durability(item_id)
        var maximum := get_max_durability(item_id)
        var row := VBoxContainer.new()
        _list.add_child(row)
        var label := Label.new()
        label.text = "%s — %d/%d" % [InventoryManager.get_item_name(item_id), current, maximum]
        row.add_child(label)
        var progress := ProgressBar.new()
        progress.min_value = 0
        progress.max_value = maximum
        progress.value = current
        progress.show_percentage = false
        row.add_child(progress)
        var repair_button := Button.new()
        var cost: Dictionary = REPAIR_COSTS.get(item_id, {})
        repair_button.text = "Perbaiki (%s)" % _format_materials(cost)
        repair_button.disabled = current >= maximum or not get_missing_repair_materials(item_id).is_empty()
        repair_button.pressed.connect(_repair_from_ui.bind(item_id))
        row.add_child(repair_button)
        _list.add_child(HSeparator.new())
    if not found:
        var empty_label := Label.new()
        empty_label.text = "Belum memiliki alat gathering. Buat kapak atau beliung melalui Crafting (C)."
        empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        _list.add_child(empty_label)

func _repair_from_ui(item_id: String) -> void:
    var result := repair_tool(item_id)
    if not bool(result.get("ok", false)):
        GameManager.notification_requested.emit(str(result.get("message", "Perbaikan gagal.")))
    _refresh_ui()
