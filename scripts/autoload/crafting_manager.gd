extends Node
## Crafting awal untuk mengolah material menjadi bahan dan consumable.

signal crafting_completed(recipe_id: String, output_id: String, amount: int)

const RECIPES := {
    "wooden_plank": {
        "name": "Papan Kayu",
        "description": "Bahan dasar perlengkapan dan konstruksi.",
        "ingredients": {"wood": 3},
        "output": "wooden_plank",
        "amount": 2
    },
    "stone_brick": {
        "name": "Batu Bata",
        "description": "Bahan konstruksi yang lebih kuat.",
        "ingredients": {"stone": 3},
        "output": "stone_brick",
        "amount": 2
    },
    "iron_ingot": {
        "name": "Batangan Besi",
        "description": "Bahan dasar perlengkapan logam.",
        "ingredients": {"iron_ore": 2, "stone": 1},
        "output": "iron_ingot",
        "amount": 1
    },
    "crystal_core": {
        "name": "Inti Kristal",
        "description": "Komponen energi dari kristal langka.",
        "ingredients": {"blue_crystal": 2, "purple_crystal": 1},
        "output": "crystal_core",
        "amount": 1
    },
    "healing_potion": {
        "name": "Ramuan Pemulih",
        "description": "Ramuan sederhana dari jamur.",
        "ingredients": {"forest_mushroom": 2, "cave_mushroom": 1},
        "output": "healing_potion",
        "amount": 1
    }
}

var _layer: CanvasLayer
var _panel: PanelContainer
var _list: VBoxContainer

func _ready() -> void:
    InventoryManager.inventory_changed.connect(_on_inventory_changed)
    _build_ui()

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_C:
        toggle_ui()
        get_viewport().set_input_as_handled()

func get_recipe_ids() -> Array[String]:
    var ids: Array[String] = []
    for key in RECIPES.keys():
        ids.append(str(key))
    ids.sort()
    return ids

func get_recipe(recipe_id: String) -> Dictionary:
    return RECIPES.get(recipe_id, {}).duplicate(true)

func get_missing_ingredients(recipe_id: String) -> Dictionary:
    var recipe: Dictionary = RECIPES.get(recipe_id, {})
    var missing: Dictionary = {}
    if recipe.is_empty():
        return missing
    var ingredients: Dictionary = recipe.get("ingredients", {})
    for key in ingredients.keys():
        var item_id := str(key)
        var required := int(ingredients[key])
        var owned := InventoryManager.get_amount(item_id)
        if owned < required:
            missing[item_id] = required - owned
    return missing

func can_craft(recipe_id: String) -> bool:
    var recipe: Dictionary = RECIPES.get(recipe_id, {})
    if recipe.is_empty() or not get_missing_ingredients(recipe_id).is_empty():
        return false
    return InventoryManager.can_add_item(str(recipe.get("output", "")), int(recipe.get("amount", 1)))

func craft(recipe_id: String) -> Dictionary:
    var recipe: Dictionary = RECIPES.get(recipe_id, {})
    if recipe.is_empty():
        return {"ok": false, "message": "Resep tidak ditemukan."}
    var missing := get_missing_ingredients(recipe_id)
    if not missing.is_empty():
        return {"ok": false, "message": "Bahan belum cukup: %s." % _format_amounts(missing)}
    var output_id := str(recipe.get("output", ""))
    var output_amount := int(recipe.get("amount", 1))
    if not InventoryManager.can_add_item(output_id, output_amount):
        return {"ok": false, "message": "Inventory penuh atau kapasitas stack hasil tidak cukup."}

    var ingredients: Dictionary = recipe.get("ingredients", {})
    for key in ingredients.keys():
        InventoryManager.remove_item(str(key), int(ingredients[key]))
    if not InventoryManager.add_item(output_id, output_amount):
        for key in ingredients.keys():
            InventoryManager.add_item(str(key), int(ingredients[key]))
        return {"ok": false, "message": "Hasil gagal disimpan; bahan dikembalikan."}

    crafting_completed.emit(recipe_id, output_id, output_amount)
    GameManager.notification_requested.emit(
        "Berhasil membuat %s x%d." % [InventoryManager.get_item_name(output_id), output_amount]
    )
    _refresh_ui()
    SaveManager.save_game()
    return {"ok": true, "message": "Crafting berhasil."}

func _format_amounts(amounts: Dictionary) -> String:
    var parts: PackedStringArray = []
    for key in amounts.keys():
        parts.append("%s x%d" % [InventoryManager.get_item_name(str(key)), int(amounts[key])])
    return ", ".join(parts)

func _build_ui() -> void:
    _layer = CanvasLayer.new()
    _layer.name = "CraftingCanvas"
    add_child(_layer)
    _panel = PanelContainer.new()
    _panel.name = "CraftingPanel"
    _panel.position = Vector2(235, 45)
    _panel.size = Vector2(490, 450)
    _panel.custom_minimum_size = Vector2(490, 450)
    _panel.visible = false
    _layer.add_child(_panel)
    var outer := VBoxContainer.new()
    _panel.add_child(outer)
    var header := HBoxContainer.new()
    outer.add_child(header)
    var title := Label.new()
    title.text = "MEJA CRAFTING"
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)
    var close_button := Button.new()
    close_button.text = "TUTUP"
    close_button.pressed.connect(toggle_ui.bind(false))
    header.add_child(close_button)
    var hint := Label.new()
    hint.text = "Tekan C untuk membuka/menutup. Bahan dipakai saat crafting berhasil."
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

func _on_inventory_changed() -> void:
    if is_instance_valid(_panel) and _panel.visible:
        _refresh_ui()

func _refresh_ui() -> void:
    if not is_instance_valid(_list):
        return
    for child in _list.get_children():
        _list.remove_child(child)
        child.free()
    for recipe_id in get_recipe_ids():
        var recipe: Dictionary = get_recipe(recipe_id)
        var row := VBoxContainer.new()
        _list.add_child(row)
        var title := Label.new()
        title.text = "%s → %s x%d" % [
            str(recipe.get("name", recipe_id)),
            InventoryManager.get_item_name(str(recipe.get("output", ""))),
            int(recipe.get("amount", 1))
        ]
        row.add_child(title)
        var details: PackedStringArray = []
        var ingredients: Dictionary = recipe.get("ingredients", {})
        for key in ingredients.keys():
            var item_id := str(key)
            details.append("%s %d/%d" % [
                InventoryManager.get_item_name(item_id),
                InventoryManager.get_amount(item_id),
                int(ingredients[key])
            ])
        var description := Label.new()
        description.text = "Bahan: %s\n%s" % [", ".join(details), str(recipe.get("description", ""))]
        description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        row.add_child(description)
        var button := Button.new()
        button.text = "BUAT"
        button.disabled = not can_craft(recipe_id)
        button.pressed.connect(_craft_from_ui.bind(recipe_id))
        row.add_child(button)
        _list.add_child(HSeparator.new())

func _craft_from_ui(recipe_id: String) -> void:
    var result := craft(recipe_id)
    if not bool(result.get("ok", false)):
        GameManager.notification_requested.emit(str(result.get("message", "Crafting gagal.")))
    _refresh_ui()
