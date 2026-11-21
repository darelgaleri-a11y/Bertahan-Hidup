extends Node

signal stats_changed

# Status dasar pada Job Level 1. Nilai berikut bertambah otomatis setiap kenaikan Job Level.
const BASE_STATS := {
    "strength": 10,
    "vitality": 10,
    "defense": 5,
    "agility": 5,
    "ability": 5,
    "stamina": 10
}
const PER_LEVEL_GROWTH := {
    "strength": 2,
    "vitality": 2,
    "defense": 1,
    "agility": 1,
    "ability": 1,
    "stamina": 2
}
const STAT_LABELS := {
    "strength": "Strength / Kekuatan",
    "vitality": "Vitality / Vitalitas",
    "defense": "Defense / Pertahanan",
    "agility": "Agility / Kelincahan",
    "ability": "Ability / Kemampuan",
    "stamina": "Stamina / Daya Tahan"
}
const STAT_DESCRIPTIONS := {
    "strength": "Menambah damage serangan dasar.",
    "vitality": "Menambah HP maksimum.",
    "defense": "Mengurangi damage yang diterima.",
    "agility": "Menambah kecepatan gerak.",
    "ability": "Disiapkan untuk efektivitas skill.",
    "stamina": "Disiapkan untuk sistem stamina dan aktivitas."
}

func _ready() -> void:
    if is_instance_valid(GameManager):
        GameManager.farm_value_changed.connect(_on_progression_changed)

func _on_progression_changed(_value: int) -> void:
    stats_changed.emit()

func get_stat(stat_name: String) -> int:
    if not BASE_STATS.has(stat_name):
        return 0
    var level_bonus := maxi(0, GameManager.job_level - 1)
    return int(BASE_STATS[stat_name]) + int(PER_LEVEL_GROWTH[stat_name]) * level_bonus

func get_all_stats() -> Dictionary:
    var result: Dictionary = {}
    for stat_name in BASE_STATS:
        result[stat_name] = get_stat(stat_name)
    return result

func get_stat_label(stat_name: String) -> String:
    return str(STAT_LABELS.get(stat_name, stat_name.capitalize()))

func get_stat_description(stat_name: String) -> String:
    return str(STAT_DESCRIPTIONS.get(stat_name, ""))

func get_save_data() -> Dictionary:
    # Status berasal dari Job Level; tidak perlu disimpan terpisah agar tidak desinkron.
    return {"derived_from_job_level": true}
