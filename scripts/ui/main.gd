extends Node2D

@onready var player: CharacterBody2D = $Player
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
var _shop_panel: PanelContainer
var _shop_money: Label
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
    GameManager.notification_requested.connect(_show_message)
    GameManager.money_changed.connect(_refresh_money)
    GameManager.farm_value_changed.connect(_refresh_money)
    FarmManager.pond_changed.connect(_refresh)
    InventoryManager.inventory_changed.connect(_refresh_inventory)
    _create_inventory_ui()
    _create_shop_ui()
    _create_mobile_controls()
    _refresh()
    _refresh_money()
    _refresh_inventory()
    _on_player_health_changed(int(player.get("health")), int(player.get("max_health")))
    _show_message("E: kolam | I: inventory | B: toko | J/Space: serang.")

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
    var distance := player.global_position.distance_to(Vector2(520, 270))
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
        _show_message("Ahli Breeding: layanan penggabungan bibit belum aktif. Fitur ini akan dibuat pada tahap Breeding System.")
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
    money_label.text = "Money: %d | Job Level: %d | Farm Value: %d" % [
        GameManager.money, GameManager.job_level, GameManager.farm_value
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
        _refresh_inventory()

func _refresh_inventory() -> void:
    if not is_instance_valid(_inventory_list):
        return
    for child in _inventory_list.get_children():
        _inventory_list.remove_child(child)
        child.free()
    _inventory_capacity.text = "Slot: %d/%d" % [InventoryManager.get_used_slots(), InventoryManager.SLOT_LIMIT]
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
