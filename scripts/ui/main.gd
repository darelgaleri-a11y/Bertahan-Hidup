extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var info_label: Label = $CanvasLayer/Panel/VBox/Info
@onready var money_label: Label = $CanvasLayer/Panel/VBox/Money
@onready var message_label: Label = $CanvasLayer/Message

func _ready() -> void:
    SaveManager.load_game()
    FarmManager.initialize_if_needed()
    GameManager.notification_requested.connect(_show_message)
    FarmManager.pond_changed.connect(_refresh)
    GameManager.money_changed.connect(_refresh_money)
    _refresh()
    _refresh_money()
    _show_message("Selamat datang! Dekati kolam dan tekan E.")

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("interact"):
        _interact()

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
