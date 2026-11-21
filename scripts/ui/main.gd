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

const FARM_TICK_INTERVAL := 1.0
const AUTOSAVE_INTERVAL := 30.0
const PLAYER_START_POSITION := Vector2(380, 270)

func _ready() -> void:
    player.add_to_group("player")
    player.connect("health_changed", Callable(self, "_on_player_health_changed"))
    player.connect("player_defeated", Callable(self, "_on_player_defeated"))

    SaveManager.load_game()
    FarmManager.initialize_if_needed()
    GameManager.notification_requested.connect(_show_message)
    FarmManager.pond_changed.connect(_refresh)
    GameManager.money_changed.connect(_refresh_money)
    GameManager.farm_value_changed.connect(_refresh_money)

    _refresh()
    _refresh_money()
    _on_player_health_changed(int(player.get("health")), int(player.get("max_health")))
    _create_mobile_controls()
    _show_message("Dekati kolam dan tekan E. Dekati Slime lalu tekan J/Space.")

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

    if Input.is_action_just_pressed("interact"):
        _interact()
    if Input.is_action_just_pressed("attack"):
        _attack()


func _create_mobile_controls() -> void:
    if not OS.has_feature("mobile") and not DisplayServer.is_touchscreen_available():
        return

    _add_touch_button("↑", Vector2(82, 350), "move_up")
    _add_touch_button("←", Vector2(22, 405), "move_left")
    _add_touch_button("→", Vector2(142, 405), "move_right")
    _add_touch_button("↓", Vector2(82, 460), "move_down")
    _add_touch_button("INTERAKSI", Vector2(748, 420), "interact", Vector2(92, 58))
    _add_touch_button("SERANG", Vector2(850, 420), "attack", Vector2(88, 58))

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

func _interact() -> void:
    var distance := player.global_position.distance_to(Vector2(520, 270))
    if distance > 95.0:
        _show_message("Dekati kolam terlebih dahulu.")
        return

    if FarmManager.fish_count == 0:
        if FarmManager.add_fish():
            _show_message("Bibit Basic dimasukkan ke kolam.")
        else:
            _show_message("Tidak ada bibit Basic di inventory.")
    elif FarmManager.fish_ready:
        if FarmManager.harvest():
            _show_message("Panen berhasil! Ikan masuk inventory.")
    elif FarmManager.feed_count < 2:
        if FarmManager.add_feed():
            _show_message("Pakan ditambahkan ke kolam.")
        else:
            _show_message("Pakan Basic tidak tersedia.")
    else:
        _show_message("Kolam berjalan. Pakan tersisa: %d" % FarmManager.feed_count)
    _refresh()

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
    if not is_instance_valid(player):
        return
    var maximum_health := int(player.get("max_health"))
    player.set("health", maximum_health)
    player.global_position = PLAYER_START_POSITION
    player.emit_signal("health_changed", maximum_health, maximum_health)
    _show_message("Pemain pulih. Hati-hati terhadap monster!")
    _is_respawning = false

func _refresh() -> void:
    info_label.text = "Kolam: %d/%d ikan | Pakan: %d | Progres: %d%% | Siap panen: %s" % [
        FarmManager.fish_count,
        10,
        FarmManager.feed_count,
        int(FarmManager.growth_progress * 100.0),
        "Ya" if FarmManager.fish_ready else "Belum"
    ]

func _refresh_money(_value: int = 0) -> void:
    money_label.text = "Money: %d | Job Level: %d | Farm Value: %d" % [
        GameManager.money, GameManager.job_level, GameManager.farm_value
    ]

func _show_message(message: String) -> void:
    message_label.text = message

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        SaveManager.save_game()
        get_tree().quit()
