extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var info_label: Label = $CanvasLayer/Panel/VBox/Info
@onready var money_label: Label = $CanvasLayer/Panel/VBox/Money
@onready var message_label: Label = $CanvasLayer/Message
@onready var combat_label: Label = $CanvasLayer/CombatInfo

var _farm_tick_timer: float = 0.0
var _autosave_timer: float = 0.0
const FARM_TICK_INTERVAL := 1.0
const AUTOSAVE_INTERVAL := 30.0

func _ready() -> void:
    player.add_to_group("player")
    SaveManager.load_game()
    FarmManager.initialize_if_needed()
    GameManager.notification_requested.connect(_show_message)
    FarmManager.pond_changed.connect(_refresh)
    GameManager.money_changed.connect(_refresh_money)
    _refresh()
    _refresh_money()
    _show_message("Selamat datang! Dekati kolam dan tekan E.")

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
        _show_message("Kolam sedang berjalan. Pakan tersisa: %d" % FarmManager.feed_count)
    _refresh()

func _refresh() -> void:
    info_label.text = "Kolam: %d/10 ikan | Pakan: %d | Progres: %d%% | Siap panen: %s" % [
        FarmManager.fish_count, FarmManager.feed_count,
        int(FarmManager.growth_progress * 100.0),
        "Ya" if FarmManager.fish_ready else "Belum"
    ]

func _refresh_money(_value: int = 0) -> void:
    money_label.text = "Money: %d   |   Job Level: %d   |   Farm Value: %d" % [
        GameManager.money, GameManager.job_level, GameManager.farm_value
    ]

func _show_message(message: String) -> void:
    message_label.text = message

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        SaveManager.save_game()
        get_tree().quit()


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

    # Fallback: scene currently contains one Slime instance.
    if nearest == null:
        var slime := get_node_or_null("Slime")
        if slime != null and is_instance_valid(slime):
            var distance := player.global_position.distance_to(slime.global_position)
            if distance <= nearest_distance:
                nearest = slime

    if nearest != null and nearest.has_method("take_damage"):
        if nearest.has_signal("defeated") and not nearest.is_connected("defeated", Callable(self, "_on_monster_defeated")):
            nearest.connect("defeated", Callable(self, "_on_monster_defeated"))
        nearest.take_damage(25)
        _show_message("Kamu menyerang Slime! (25 damage)")
    else:
        _show_message("Tidak ada monster dalam jangkauan serangan.")

func _on_monster_defeated(loot_summary: String) -> void:
    _show_message("Slime dikalahkan! Loot: " + loot_summary)
    combat_label.text = "Loot diperoleh: " + loot_summary

