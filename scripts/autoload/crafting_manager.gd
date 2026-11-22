extends Node
## Crafting bahan, perlengkapan, dan alat gathering.

signal crafting_completed(recipe_id: String, output_id: String, amount: int)

const RECIPES := {
    "wooden_plank": {"name":"Papan Kayu","category":"Bahan Dasar","description":"Bahan dasar perlengkapan dan konstruksi.","ingredients":{"wood":3},"output":"wooden_plank","amount":2},
    "stone_brick": {"name":"Batu Bata","category":"Bahan Dasar","description":"Bahan konstruksi yang lebih kuat.","ingredients":{"stone":3},"output":"stone_brick","amount":2},
    "iron_ingot": {"name":"Batangan Besi","category":"Bahan Dasar","description":"Bahan dasar perlengkapan logam.","ingredients":{"iron_ore":2,"stone":1},"output":"iron_ingot","amount":1},
    "crystal_core": {"name":"Inti Kristal","category":"Bahan Dasar","description":"Komponen energi dari kristal langka.","ingredients":{"blue_crystal":2,"purple_crystal":1},"output":"crystal_core","amount":1},
    "healing_potion": {"name":"Ramuan Pemulih","category":"Ramuan","description":"Ramuan sederhana dari jamur.","ingredients":{"forest_mushroom":2,"cave_mushroom":1},"output":"healing_potion","amount":1},
    "workbench_basic": {"name":"Meja Kerja Dasar","category":"Stasiun Kerja","description":"Membuka resep perlengkapan tingkat lanjut.","ingredients":{"wooden_plank":6,"stone_brick":4},"output":"workbench_basic","amount":1},
    "wooden_axe": {"name":"Kapak Kayu","category":"Peralatan","description":"Alat dasar untuk mengumpulkan kayu.","ingredients":{"wooden_plank":3,"stone":2},"output":"wooden_axe","amount":1},
    "wooden_pickaxe": {"name":"Beliung Kayu","category":"Peralatan","description":"Alat dasar untuk menambang mineral.","ingredients":{"wooden_plank":3,"stone":3},"output":"wooden_pickaxe","amount":1},
    "iron_sword": {"name":"Pedang Besi","category":"Perlengkapan Lanjutan","description":"Senjata lebih kuat untuk menghadapi monster.","station":"workbench_basic","ingredients":{"iron_ingot":5,"wooden_plank":2,"wolf_fang":2},"output":"iron_sword","amount":1},
    "reinforced_armor": {"name":"Zirah Perkuatan","category":"Perlengkapan Lanjutan","description":"Armor dengan pertahanan lebih baik.","station":"workbench_basic","ingredients":{"iron_ingot":4,"stone_brick":3,"beast_claw":1},"output":"reinforced_armor","amount":1},
    "iron_axe": {"name":"Kapak Besi","category":"Peralatan","description":"Kapak tingkat lanjut dengan hasil gathering lebih banyak.","station":"workbench_basic","ingredients":{"iron_ingot":3,"wooden_plank":2},"output":"iron_axe","amount":1},
    "iron_pickaxe": {"name":"Beliung Besi","category":"Peralatan","description":"Beliung tingkat lanjut dengan hasil mining lebih banyak.","station":"workbench_basic","ingredients":{"iron_ingot":3,"wooden_plank":2,"stone":2},"output":"iron_pickaxe","amount":1},
    "greater_potion": {"name":"Ramuan Pemulih Besar","category":"Ramuan","description":"Ramuan tingkat lanjut.","station":"workbench_basic","ingredients":{"healing_potion":2,"crystal_core":1,"cave_mushroom":2},"output":"greater_potion","amount":1}
}

var _layer: CanvasLayer
var _panel: PanelContainer
var _list: VBoxContainer
var _category_picker: OptionButton
var _active_category := "Semua"

func _ready() -> void:
    InventoryManager.inventory_changed.connect(_on_inventory_changed)
    _build_ui()

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_C:
        toggle_ui()
        get_viewport().set_input_as_handled()

func get_recipe_ids(category_filter: String = "Semua") -> Array[String]:
    var ids: Array[String] = []
    for key in RECIPES.keys():
        var recipe: Dictionary = RECIPES[key]
        if category_filter == "Semua" or str(recipe.get("category", "")) == category_filter:
            ids.append(str(key))
    ids.sort()
    return ids

func get_categories() -> Array[String]:
    var categories: Array[String] = ["Semua"]
    for recipe in RECIPES.values():
        var category := str(recipe.get("category", "Lainnya"))
        if not categories.has(category):
            categories.append(category)
    categories.sort()
    categories.erase("Semua")
    categories.push_front("Semua")
    return categories

func get_recipe(recipe_id: String) -> Dictionary:
    return RECIPES.get(recipe_id, {}).duplicate(true)

func has_required_station(recipe_id: String) -> bool:
    var recipe: Dictionary = RECIPES.get(recipe_id, {})
    var station := str(recipe.get("station", ""))
    return station == "" or InventoryManager.get_amount(station) > 0

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
    if recipe.is_empty() or not has_required_station(recipe_id):
        return false
    if not get_missing_ingredients(recipe_id).is_empty():
        return false
    return InventoryManager.can_add_item(str(recipe.get("output", "")), int(recipe.get("amount", 1)))

func craft(recipe_id: String) -> Dictionary:
    var recipe: Dictionary = RECIPES.get(recipe_id, {})
    if recipe.is_empty():
        return {"ok": false, "message": "Resep tidak ditemukan."}
    if not has_required_station(recipe_id):
        return {"ok": false, "message": "Buat dan simpan Meja Kerja Dasar terlebih dahulu."}
    var missing := get_missing_ingredients(recipe_id)
    if not missing.is_empty():
        return {"ok": false, "message": "Bahan belum cukup: %s." % _format_amounts(missing)}
    var output_id := str(recipe.get("output", ""))
    var output_amount := int(recipe.get("amount", 1))
    if not InventoryManager.can_add_item(output_id, output_amount):
        return {"ok": false, "message": "Inventory penuh atau kapasitas stack hasil tidak cukup."}
    var ingredients: Dictionary = recipe.get("ingredients", {})
    for key in ingredients.keys():
        if not InventoryManager.remove_item(str(key), int(ingredients[key])):
            for rollback_key in ingredients.keys():
                InventoryManager.add_item(str(rollback_key), int(ingredients[rollback_key]))
            return {"ok": false, "message": "Gagal mengambil bahan crafting."}
    if not InventoryManager.add_item(output_id, output_amount):
        for key in ingredients.keys():
            InventoryManager.add_item(str(key), int(ingredients[key]))
        return {"ok": false, "message": "Hasil gagal disimpan; bahan dikembalikan."}
    crafting_completed.emit(recipe_id, output_id, output_amount)
    GameManager.notification_requested.emit("Berhasil membuat %s x%d." % [InventoryManager.get_item_name(output_id), output_amount])
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
    _panel.position = Vector2(190, 35)
    _panel.size = Vector2(580, 470)
    _panel.custom_minimum_size = Vector2(580, 470)
    _panel.visible = false
    _layer.add_child(_panel)
    var outer := VBoxContainer.new()
    _panel.add_child(outer)
    var header := HBoxContainer.new()
    outer.add_child(header)
    var title := Label.new()
    title.text = "WORKBENCH & CRAFTING"
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)
    var close_button := Button.new()
    close_button.text = "TUTUP"
    close_button.pressed.connect(toggle_ui.bind(false))
    header.add_child(close_button)
    var hint := Label.new()
    hint.text = "Tekan C untuk membuka/menutup. Resep lanjutan membutuhkan Meja Kerja Dasar."
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    outer.add_child(hint)
    _category_picker = OptionButton.new()
    _category_picker.item_selected.connect(_on_category_selected)
    outer.add_child(_category_picker)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    outer.add_child(scroll)
    _list = VBoxContainer.new()
    _list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(_list)
    _populate_categories()
    _refresh_ui()

func _populate_categories() -> void:
    if not is_instance_valid(_category_picker):
        return
    _category_picker.clear()
    for category in get_categories():
        _category_picker.add_item(category)
    _category_picker.select(0)

func _on_category_selected(index: int) -> void:
    if index >= 0 and index < _category_picker.item_count:
        _active_category = _category_picker.get_item_text(index)
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
        child.queue_free()
    for recipe_id in get_recipe_ids(_active_category):
        var recipe: Dictionary = get_recipe(recipe_id)
        var row := VBoxContainer.new()
        _list.add_child(row)
        var title := Label.new()
        title.text = "%s → %s x%d" % [str(recipe.get("name", recipe_id)), InventoryManager.get_item_name(str(recipe.get("output", ""))), int(recipe.get("amount", 1))]
        row.add_child(title)
        var details: PackedStringArray = []
        var ingredients: Dictionary = recipe.get("ingredients", {})
        for key in ingredients.keys():
            var item_id := str(key)
            details.append("%s %d/%d" % [InventoryManager.get_item_name(item_id), InventoryManager.get_amount(item_id), int(ingredients[key])])
        var station_text := ""
        if not has_required_station(recipe_id):
            station_text = "\nSyarat: Meja Kerja Dasar belum dimiliki."
        var description := Label.new()
        description.text = "Bahan: %s\n%s%s" % [", ".join(details), str(recipe.get("description", "")), station_text]
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
