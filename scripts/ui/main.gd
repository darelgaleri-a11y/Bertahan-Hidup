extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var pond: Sprite2D = $Pond
@onready var info_label: Label = $CanvasLayer/Panel/VBox/Info
@onready var money_label: Label = $CanvasLayer/Panel/VBox/Money
@onready var message_label: Label = $CanvasLayer/Message
@onready var combat_label: Label = $CanvasLayer/CombatInfo
@onready var health_label: Label = $CanvasLayer/PlayerHealth

var _farm_tick_timer: float = 0.0
var _autosave_timer: float = 0.0
var _is_respawning: bool = false
var _inventory_panel: PanelContainer
var _inventory_list: VBoxContainer
var _inventory_capacity: Label
var _loot_button: Button
var _shop_panel: PanelContainer
var _shop_money: Label
var _breeding_panel: PanelContainer
var _breeding_content: VBoxContainer
var _property_panel: PanelContainer
var _property_content: VBoxContainer
var _relocation_cart: Sprite2D
var _relocating: bool = false
var _inventory_open := false
var _shop_open := false
var _last_npc_id: String = ""

const NPC_INTERACTION_RANGE := 62.0

const FARM_TICK_INTERVAL := 1.0
const AUTOSAVE_INTERVAL := 30.0
const PLAYER_START_POSITION := Vector2(380, 270)
const SHOP_ITEMS := {
    "seed_basic": {"price": 75, "label": "Bibit Basic"},
    "feed_basic": {"price": 10, "label": "Pakan Basic"}
}

func _ready() -> void:
    player.add_to_group("player")
    player.connect("health_changed", Callable(self, "_on_player_health_changed"))
    player.connect("player_defeated", Callable(self, "_on_player_defeated"))
    SaveManager.load_game()
    FarmManager.initialize_if_needed()
    PropertyManager.initialize_if_needed()
    PropertyManager.relocation_started.connect(_on_relocation_started)
    _apply_current_land_position()
    GameManager.notification_requested.connect(_show_message)
    GameManager.money_changed.connect(_refresh_money)
    GameManager.farm_value_changed.connect(_refresh_money)
    FarmManager.pond_changed.connect(_refresh)
    InventoryManager.inventory_changed.connect(_refresh_inventory)
    LootManager.loot_changed.connect(_refresh_loot_button)
    _create_inventory_ui()
    _create_shop_ui()
    _create_breeding_ui()
    _create_mobile_controls()
    _refresh()
    _refresh_money()
    _refresh_inventory()
    _on_player_health_changed(int(player.get("health")), int(player.get("max_health")))
    _show_message("E: kolam | I: inventory | B: toko | J/Space: serang.")
    _create_property_ui()

func _process(delta: float) -> void:
    _farm_tick_timer += delta
    _autosave_timer += delta
    if _farm_tick_timer >= FARM_TICK_INTERVAL:
        _farm_tick_timer = 0.0
        FarmManager.update_offline()
        _refresh()
    if _autosave_timer >= AUTOSAVE_INTERVAL:
        _autosave_timer = 0.0
        SaveManager.save_game()
    if _last_npc_id != "":
        var still_near_last_npc := false
        for npc in get_tree().get_nodes_in_group("npcs"):
            if is_instance_valid(npc) and str(npc.get("npc_id")) == _last_npc_id:
                if player.global_position.distance_to(npc.global_position) <= NPC_INTERACTION_RANGE:
                    still_near_last_npc = true
                    break
        if not still_near_last_npc:
            _last_npc_id = ""

    if not bool(player.get("is_defeated")):
        if Input.is_action_just_pressed("interact"):
            _interact()
        if Input.is_action_just_pressed("attack"):
            _attack()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_I:
            _toggle_inventory()
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_B:
            _toggle_shop()
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_ESCAPE:
            if _shop_open:
                _toggle_shop(false)
            elif _inventory_open:
                _toggle_inventory(false)
            elif is_instance_valid(_breeding_panel) and _breeding_panel.visible:
                _toggle_breeding(false)
            elif is_instance_valid(_property_panel) and _property_panel.visible:
                _toggle_property(false)
            get_viewport().set_input_as_handled()

func _interact() -> void:
    # NPC diprioritaskan agar interaksi tidak salah diarahkan ke kolam di dekatnya.
    var nearest_npc: Node2D = null
    var nearest_npc_distance := NPC_INTERACTION_RANGE
    for npc in get_tree().get_nodes_in_group("npcs"):
        if not is_instance_valid(npc):
            continue
        var npc_distance := player.global_position.distance_to(npc.global_position)
        if npc_distance <= nearest_npc_distance:
            nearest_npc = npc
            nearest_npc_distance = npc_distance

    if nearest_npc != null:
        _interact_with_npc(nearest_npc)
        return

    _last_npc_id = ""
    var distance := player.global_position.distance_to(pond.global_position)
    if distance > 95.0:
        _show_message("Dekati kolam atau penduduk terlebih dahulu.")
        return
    if FarmManager.fish_count == 0:
        if FarmManager.add_fish():
            _show_message("Bibit Basic dimasukkan. Tambahkan pakan untuk memulai pertumbuhan.")
        else:
            _show_message("Tidak ada bibit Basic di inventory.")
    elif FarmManager.fish_ready:
        if FarmManager.harvest():
            _show_message("Panen berhasil! Ikan masuk inventory.")
    elif FarmManager.feed_count == 0:
        if FarmManager.add_feed():
            _show_message("Pakan ditambahkan ke kolam.")
        else:
            _show_message("Pakan Basic tidak tersedia.")
    else:
        _show_message("Kolam berjalan. Pakan tersisa: %d" % FarmManager.feed_count)
    _refresh()

func _interact_with_npc(npc: Node2D) -> void:
    var npc_id := str(npc.get("npc_id"))
    var npc_name := str(npc.get("display_name"))
    var greeting := str(npc.get("greeting"))

    if npc_id != _last_npc_id:
        _last_npc_id = npc_id
        _show_message("%s: %s" % [npc_name, greeting])
        return

    if npc_id == "shopkeeper":
        _toggle_shop(true)
        _show_message("Toko dibuka. Pilih perlengkapan yang ingin dibeli.")
    elif npc_id == "breeder":
        _toggle_breeding(true)
        _show_message("Pilih dua bibit dengan tier sama untuk mencoba menaikkan kualitasnya.")
    elif npc_id == "property_agent":
        _toggle_property(true)
        _show_message("Pilih lahan untuk disewa, dibeli, atau ditempati.")
    else:
        _show_message("%s: Senang bertemu denganmu!" % npc_name)

func _attack() -> void:
    var nearest: Node2D = null
    var nearest_distance := 48.0
    for monster in get_tree().get_nodes_in_group("monsters"):
        if not is_instance_valid(monster):
            continue
        var distance := player.global_position.distance_to(monster.global_position)
        if distance < nearest_distance:
            nearest = monster
            nearest_distance = distance
    if nearest != null and nearest.has_method("take_damage"):
        if nearest.has_signal("defeated"):
            var callback := Callable(self, "_on_monster_defeated")
            if not nearest.is_connected("defeated", callback):
                nearest.connect("defeated", callback)
        nearest.take_damage(25)
        _show_message("Serangan mengenai Slime: 25 damage.")
    else:
        _show_message("Tidak ada monster dalam jangkauan serangan.")

func _on_monster_defeated(loot_summary: String) -> void:
    _show_message("Slime dikalahkan! Loot: " + loot_summary)
    combat_label.text = "Loot: " + loot_summary

func _on_player_health_changed(current: int, maximum: int) -> void:
    health_label.text = "HP Pemain: %d/%d" % [current, maximum]

func _on_player_defeated() -> void:
    if _is_respawning:
        return
    _is_respawning = true
    _show_message("Kamu kalah! Pemain akan pulih kembali.")
    await get_tree().create_timer(1.5).timeout
    if is_instance_valid(player):
        player.call("restore_after_defeat", PLAYER_START_POSITION)
        _show_message("Pemain pulih. Hati-hati terhadap monster!")
    _is_respawning = false

func _refresh() -> void:
    info_label.text = "Kolam: %d/10 ikan | Pakan: %d | Progres: %d%% | Siap panen: %s" % [
        FarmManager.fish_count, FarmManager.feed_count,
        int(FarmManager.growth_progress * 100.0),
        "Ya" if FarmManager.fish_ready else "Belum"
    ]

func _refresh_money(_value: int = 0) -> void:
    money_label.text = "Money: %d | Job Level: %d | Farm Value: %d | %s" % [
        GameManager.money, GameManager.job_level, GameManager.farm_value,
        PropertyManager.get_current_land_name()
    ]
    if is_instance_valid(_shop_money):
        _shop_money.text = "Money tersedia: %d" % GameManager.money

func _show_message(message: String) -> void:
    message_label.text = message

func _create_inventory_ui() -> void:
    _inventory_panel = PanelContainer.new()
    _inventory_panel.name = "InventoryPanel"
    _inventory_panel.position = Vector2(300, 100)
    _inventory_panel.size = Vector2(360, 340)
    _inventory_panel.custom_minimum_size = Vector2(360, 340)
    _inventory_panel.visible = false
    $CanvasLayer.add_child(_inventory_panel)
    var outer := VBoxContainer.new()
    outer.name = "InventoryContent"
    _inventory_panel.add_child(outer)
    var header := HBoxContainer.new()
    outer.add_child(header)
    var title := Label.new()
    title.text = "INVENTORY"
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)
    var close_button := Button.new()
    close_button.text = "TUTUP"
    close_button.pressed.connect(_toggle_inventory.bind(false))
    header.add_child(close_button)
    _inventory_capacity = Label.new()
    outer.add_child(_inventory_capacity)
    _loot_button = Button.new()
    _loot_button.text = "AMBIL LOOT"
    _loot_button.custom_minimum_size = Vector2(0, 42)
    _loot_button.pressed.connect(_claim_loot)
    outer.add_child(_loot_button)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    outer.add_child(scroll)
    _inventory_list = VBoxContainer.new()
    _inventory_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(_inventory_list)

func _toggle_inventory(force_state: Variant = null) -> void:
    _inventory_open = not _inventory_open if force_state == null else bool(force_state)
    _inventory_panel.visible = _inventory_open
    if _inventory_open:
        _toggle_shop(false)
        if is_instance_valid(_breeding_panel):
            _toggle_breeding(false)
        if is_instance_valid(_property_panel):
            _toggle_property(false)
        _refresh_inventory()

func _refresh_inventory() -> void:
    if not is_instance_valid(_inventory_list):
        return
    for child in _inventory_list.get_children():
        _inventory_list.remove_child(child)
        child.free()
    _inventory_capacity.text = "Slot: %d/%d" % [InventoryManager.get_used_slots(), InventoryManager.SLOT_LIMIT]
    _refresh_loot_button()
    if InventoryManager.items.is_empty():
        var empty_label := Label.new()
        empty_label.text = "Inventory kosong."
        _inventory_list.add_child(empty_label)
        return
    var ids: Array = InventoryManager.items.keys()
    ids.sort()
    for value in ids:
        var item_id := str(value)
        var row := HBoxContainer.new()
        _inventory_list.add_child(row)
        var item_label := Label.new()
        item_label.text = "%s x%d" % [InventoryManager.get_item_name(item_id), InventoryManager.get_amount(item_id)]
        item_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(item_label)
        var price := InventoryManager.get_sell_price(item_id)
        if price > 0:
            var sell_button := Button.new()
            sell_button.text = "Jual %d" % price
            sell_button.custom_minimum_size = Vector2(90, 42)
            sell_button.pressed.connect(_sell_item.bind(item_id))
            row.add_child(sell_button)

func _sell_item(item_id: String) -> void:
    var price := InventoryManager.get_sell_price(item_id)
    if InventoryManager.sell_item(item_id, 1):
        _show_message("%s terjual. +%d Money." % [InventoryManager.get_item_name(item_id), price])
    else:
        _show_message("Penjualan gagal.")
    _refresh_money()
    _refresh_inventory()

func _refresh_loot_button() -> void:
    if not is_instance_valid(_loot_button):
        return
    var pending := LootManager.get_pending_count()
    _loot_button.text = "AMBIL LOOT (%d)" % pending
    _loot_button.disabled = pending <= 0

func _claim_loot() -> void:
    var claimed := LootManager.claim_pending_loot()
    if claimed > 0:
        _show_message("Berhasil mengambil %d item dari Peti Loot." % claimed)
    else:
        _show_message("Inventory penuh. Kosongkan slot atau stack terlebih dahulu.")
    _refresh_inventory()
    _refresh_loot_button()

func _create_shop_ui() -> void:
    _shop_panel = PanelContainer.new()
    _shop_panel.name = "ShopPanel"
    _shop_panel.position = Vector2(300, 115)
    _shop_panel.size = Vector2(360, 300)
    _shop_panel.custom_minimum_size = Vector2(360, 300)
    _shop_panel.visible = false
    $CanvasLayer.add_child(_shop_panel)
    var outer := VBoxContainer.new()
    _shop_panel.add_child(outer)
    var header := HBoxContainer.new()
    outer.add_child(header)
    var title := Label.new()
    title.text = "TOKO PERLENGKAPAN"
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)
    var close_button := Button.new()
    close_button.text = "TUTUP"
    close_button.pressed.connect(_toggle_shop.bind(false))
    header.add_child(close_button)
    _shop_money = Label.new()
    outer.add_child(_shop_money)
    var hint := Label.new()
    hint.text = "Pilih item untuk membeli 1 unit."
    outer.add_child(hint)
    for item_id in SHOP_ITEMS.keys():
        var item_data: Dictionary = SHOP_ITEMS[item_id]
        var buy_button := Button.new()
        buy_button.text = "%s — %d Money" % [item_data["label"], item_data["price"]]
        buy_button.custom_minimum_size = Vector2(0, 48)
        buy_button.pressed.connect(_buy_item.bind(str(item_id)))
        outer.add_child(buy_button)

func _toggle_shop(force_state: Variant = null) -> void:
    _shop_open = not _shop_open if force_state == null else bool(force_state)
    _shop_panel.visible = _shop_open
    if _shop_open:
        _toggle_inventory(false)
        if is_instance_valid(_breeding_panel):
            _toggle_breeding(false)
        if is_instance_valid(_property_panel):
            _toggle_property(false)
    _refresh_money()

func _buy_item(item_id: String) -> void:
    if not SHOP_ITEMS.has(item_id):
        return
    var item_data: Dictionary = SHOP_ITEMS[item_id]
    var price := int(item_data["price"])
    if GameManager.money < price:
        _show_message("Money tidak cukup.")
        return
    if InventoryManager.get_amount(item_id) >= InventoryManager.get_stack_limit(item_id):
        _show_message("Stack item sudah penuh.")
        return
    if InventoryManager.get_amount(item_id) == 0 and InventoryManager.get_used_slots() >= InventoryManager.SLOT_LIMIT:
        _show_message("Inventory penuh.")
        return
    if GameManager.spend_money(price):
        if InventoryManager.add_item(item_id, 1):
            _show_message("%s berhasil dibeli." % item_data["label"])
        else:
            GameManager.add_money(price)
            _show_message("Pembelian dibatalkan. Inventory tidak dapat menerima item.")
    _refresh_money()
    _refresh_inventory()

func _create_breeding_ui() -> void:
    _breeding_panel = PanelContainer.new()
    _breeding_panel.name = "BreedingPanel"
    _breeding_panel.position = Vector2(285, 75)
    _breeding_panel.size = Vector2(390, 390)
    _breeding_panel.custom_minimum_size = Vector2(390, 390)
    _breeding_panel.visible = false
    $CanvasLayer.add_child(_breeding_panel)

    var outer := VBoxContainer.new()
    _breeding_panel.add_child(outer)
    var header := HBoxContainer.new()
    outer.add_child(header)
    var title := Label.new()
    title.text = "BREEDING BIBIT"
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)
    var close_button := Button.new()
    close_button.text = "TUTUP"
    close_button.pressed.connect(_toggle_breeding.bind(false))
    header.add_child(close_button)

    var explanation := Label.new()
    explanation.text = "Gunakan 2 bibit satu tier + biaya Money. Peluang sukses berbeda tiap tier."
    explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    outer.add_child(explanation)

    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    outer.add_child(scroll)
    _breeding_content = VBoxContainer.new()
    _breeding_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(_breeding_content)
    _refresh_breeding_ui()

func _toggle_breeding(force_state: Variant = null) -> void:
    if not is_instance_valid(_breeding_panel):
        return
    var open := not _breeding_panel.visible if force_state == null else bool(force_state)
    _breeding_panel.visible = open
    if open:
        _toggle_shop(false)
        _toggle_inventory(false)
        if is_instance_valid(_property_panel):
            _toggle_property(false)
        _refresh_breeding_ui()

func _refresh_breeding_ui() -> void:
    if not is_instance_valid(_breeding_content):
        return
    for child in _breeding_content.get_children():
        _breeding_content.remove_child(child)
        child.free()

    var tier_ids := ["seed_basic", "seed_advanced", "seed_rare", "seed_epic"]
    for seed_id in tier_ids:
        var recipe: Dictionary = BreedingManager.get_recipe(seed_id)
        if recipe.is_empty():
            continue
        var count := InventoryManager.get_amount(seed_id)
        var row := VBoxContainer.new()
        _breeding_content.add_child(row)
        var detail := Label.new()
        detail.text = "%s → %s | Milik: %d | Biaya: %d | Peluang: %d%%" % [
            InventoryManager.get_item_name(seed_id),
            InventoryManager.get_item_name(str(recipe["output"])),
            count, int(recipe["fee"]), int(float(recipe["chance"]) * 100.0)
        ]
        detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        row.add_child(detail)
        var action := Button.new()
        action.text = "Gabungkan 2 Bibit"
        action.disabled = count < 2 or GameManager.money < int(recipe["fee"])
        action.custom_minimum_size = Vector2(0, 42)
        action.pressed.connect(_attempt_breeding.bind(seed_id))
        row.add_child(action)

func _attempt_breeding(seed_id: String) -> void:
    var result: Dictionary = BreedingManager.attempt_breeding(seed_id)
    _show_message(str(result.get("message", "Breeding selesai.")))
    _refresh_money()
    _refresh_inventory()
    _refresh_breeding_ui()

func _create_property_ui() -> void:
    _property_panel = PanelContainer.new()
    _property_panel.name = "PropertyPanel"
    _property_panel.position = Vector2(235, 55)
    _property_panel.size = Vector2(490, 430)
    _property_panel.custom_minimum_size = Vector2(490, 430)
    _property_panel.visible = false
    $CanvasLayer.add_child(_property_panel)

    var outer := VBoxContainer.new()
    _property_panel.add_child(outer)
    var header := HBoxContainer.new()
    outer.add_child(header)
    var title := Label.new()
    title.text = "LAHAN & PROPERTI"
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)
    var close_button := Button.new()
    close_button.text = "TUTUP"
    close_button.pressed.connect(_toggle_property.bind(false))
    header.add_child(close_button)
    var hint := Label.new()
    hint.text = "Sewa berlaku 7 hari. Harga berikut adalah nilai uji sementara."
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    outer.add_child(hint)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    outer.add_child(scroll)
    _property_content = VBoxContainer.new()
    _property_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(_property_content)
    _refresh_property_ui()

func _toggle_property(force_state: Variant = null) -> void:
    if not is_instance_valid(_property_panel):
        return
    var open := not _property_panel.visible if force_state == null else bool(force_state)
    _property_panel.visible = open
    if open:
        _toggle_shop(false)
        _toggle_inventory(false)
        _toggle_breeding(false)
        _refresh_property_ui()

func _refresh_property_ui() -> void:
    if not is_instance_valid(_property_content):
        return
    for child in _property_content.get_children():
        _property_content.remove_child(child)
        child.free()
    var current_label := Label.new()
    current_label.text = "Lokasi aktif: %s" % PropertyManager.get_current_land_name()
    current_label.add_theme_color_override("font_color", Color(0.35, 0.85, 0.45))
    _property_content.add_child(current_label)

    for land_id_value in ["village", "forest", "lakeside"]:
        var land_id := str(land_id_value)
        var data: Dictionary = PropertyManager.get_land_data(land_id)
        var status := PropertyManager.get_land_status(land_id)
        var row := VBoxContainer.new()
        _property_content.add_child(row)
        var detail := Label.new()
        var status_text := status.to_upper()
        if status == "rented":
            status_text += " — sisa %d hari" % PropertyManager.get_remaining_rent_days(land_id)
        detail.text = "%s | %s | Sewa: %d | Beli: %d | Job Lv.%d" % [
            str(data.get("name", land_id)), status_text,
            int(data.get("rent_price", 0)), int(data.get("buy_price", 0)),
            int(data.get("min_job_level", 1))
        ]
        detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        row.add_child(detail)
        var actions := HBoxContainer.new()
        row.add_child(actions)

        var rent_button := Button.new()
        rent_button.text = "Sewa 7 Hari"
        rent_button.disabled = status == "owned" or GameManager.job_level < int(data.get("min_job_level", 1))
        rent_button.pressed.connect(_property_action.bind("rent", land_id))
        actions.add_child(rent_button)

        var buy_button := Button.new()
        buy_button.text = "Beli"
        buy_button.disabled = status == "owned" or GameManager.job_level < int(data.get("min_job_level", 1))
        buy_button.pressed.connect(_property_action.bind("buy", land_id))
        actions.add_child(buy_button)

        var move_button := Button.new()
        move_button.text = "Pindah ke sini"
        move_button.disabled = not PropertyManager.can_access(land_id) or PropertyManager.current_land_id == land_id or _relocating
        move_button.pressed.connect(_property_action.bind("move", land_id))
        actions.add_child(move_button)

func _property_action(action: String, land_id: String) -> void:
    var result: Dictionary = {}
    if action == "rent":
        result = PropertyManager.rent_land(land_id)
    elif action == "buy":
        result = PropertyManager.buy_land(land_id)
    elif action == "move":
        result = PropertyManager.relocate_to(land_id)
    _show_message(str(result.get("message", "Aksi properti selesai.")))
    _refresh_money()
    _refresh_property_ui()
    SaveManager.save_game()

func _apply_current_land_position() -> void:
    if not is_instance_valid(pond):
        return
    var data: Dictionary = PropertyManager.get_land_data(PropertyManager.current_land_id)
    if data.is_empty():
        return
    var pond_pos: Array = data.get("pond_position", [520, 270])
    var spawn_pos: Array = data.get("spawn_position", [380, 270])
    pond.position = Vector2(float(pond_pos[0]), float(pond_pos[1]))
    if is_instance_valid(player):
        player.global_position = Vector2(float(spawn_pos[0]), float(spawn_pos[1]))

func _on_relocation_started(land_id: String) -> void:
    if _relocating:
        return
    _relocating = true
    _refresh_property_ui()
    var agent: Node2D = null
    for npc in get_tree().get_nodes_in_group("npcs"):
        if is_instance_valid(npc) and str(npc.get("npc_id")) == "property_agent":
            agent = npc as Node2D
            break
    if agent == null:
        _finish_relocation(land_id)
        return

    var target_data: Dictionary = PropertyManager.get_land_data(land_id)
    var spawn_arr: Array = target_data.get("spawn_position", [380, 270])
    var target_position := Vector2(float(spawn_arr[0]), float(spawn_arr[1]))
    var start_position := agent.global_position
    var tween := create_tween()
    tween.tween_property(agent, "global_position", (start_position + target_position) * 0.5, 0.55)
    tween.tween_property(agent, "global_position", target_position + Vector2(-42, -24), 0.55)

    var cart := Sprite2D.new()
    cart.texture = load("res://assets/sprites/moving_cart.png")
    cart.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    cart.global_position = start_position + Vector2(18, -12)
    add_child(cart)
    _relocation_cart = cart
    var cart_tween := create_tween()
    cart_tween.tween_property(cart, "global_position", target_position, 1.15)
    cart_tween.finished.connect(func():
        if is_instance_valid(cart):
            cart.queue_free()
        _finish_relocation(land_id)
    )

func _finish_relocation(land_id: String) -> void:
    _apply_current_land_position()
    _relocating = false
    if is_instance_valid(_property_panel) and _property_panel.visible:
        _refresh_property_ui()
    SaveManager.save_game()
    _show_message("Barang berhasil dipindahkan NPC. Selamat datang di %s!" % PropertyManager.get_current_land_name())

func _create_mobile_controls() -> void:
    if not OS.has_feature("mobile") and not DisplayServer.is_touchscreen_available():
        return
    _add_touch_button("↑", Vector2(82, 350), "move_up")
    _add_touch_button("←", Vector2(22, 405), "move_left")
    _add_touch_button("→", Vector2(142, 405), "move_right")
    _add_touch_button("↓", Vector2(82, 460), "move_down")
    _add_touch_button("INTERAKSI", Vector2(730, 420), "interact", Vector2(100, 58))
    _add_touch_button("SERANG", Vector2(840, 420), "attack", Vector2(90, 58))
    var bag_button := Button.new()
    bag_button.text = "TAS"
    bag_button.position = Vector2(840, 350)
    bag_button.size = Vector2(90, 54)
    $CanvasLayer.add_child(bag_button)
    bag_button.pressed.connect(_toggle_inventory)
    var shop_button := Button.new()
    shop_button.text = "TOKO"
    shop_button.position = Vector2(730, 350)
    shop_button.size = Vector2(100, 54)
    $CanvasLayer.add_child(shop_button)
    shop_button.pressed.connect(_toggle_shop)

func _add_touch_button(caption: String, button_position: Vector2, action: StringName, button_size: Vector2 = Vector2(58, 52)) -> void:
    var touch_button := Button.new()
    touch_button.text = caption
    touch_button.position = button_position
    touch_button.size = button_size
    touch_button.custom_minimum_size = button_size
    touch_button.focus_mode = Control.FOCUS_NONE
    touch_button.mouse_filter = Control.MOUSE_FILTER_STOP
    touch_button.modulate = Color(1.0, 1.0, 1.0, 0.88)
    $CanvasLayer.add_child(touch_button)
    touch_button.button_down.connect(_press_game_action.bind(action))
    touch_button.button_up.connect(_release_game_action.bind(action))

func _press_game_action(action: StringName) -> void:
    Input.action_press(action)

func _release_game_action(action: StringName) -> void:
    Input.action_release(action)

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
        SaveManager.save_game()
        if what == NOTIFICATION_WM_CLOSE_REQUEST:
            get_tree().quit()
