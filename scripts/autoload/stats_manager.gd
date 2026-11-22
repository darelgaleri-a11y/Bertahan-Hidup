extends Node

signal stats_changed

# Status dasar Job Level 1. Pertumbuhan otomatis tetap dipertahankan.
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
    "strength": "+1 damage serangan dasar untuk setiap poin alokasi.",
    "vitality": "+5 HP maksimum untuk setiap poin alokasi.",
    "defense": "Mengurangi 1 damage masuk untuk setiap poin alokasi (minimum damage tetap 1).",
    "agility": "+2 kecepatan gerak untuk setiap poin alokasi.",
    "ability": "Meningkatkan bonus efektivitas Power Strike dan Recovery.",
    "stamina": "+10 stamina maksimum dan +0,1 regenerasi stamina/detik untuk setiap poin alokasi."
}
const ALLOCATABLE_STATS := ["strength", "vitality", "defense", "agility", "ability", "stamina"]
const POINTS_PER_JOB_LEVEL := 2
const MAX_ALLOCATION_PER_STAT := 20

var _allocated_stats: Dictionary = {
    "strength": 0,
    "vitality": 0,
    "defense": 0,
    "agility": 0,
    "ability": 0,
    "stamina": 0
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
    var allocated := int(_allocated_stats.get(stat_name, 0))
    return int(BASE_STATS[stat_name]) + int(PER_LEVEL_GROWTH[stat_name]) * level_bonus + allocated

func get_all_stats() -> Dictionary:
    var result: Dictionary = {}
    for stat_name in BASE_STATS:
        result[stat_name] = get_stat(str(stat_name))
    return result

func get_stat_label(stat_name: String) -> String:
    return str(STAT_LABELS.get(stat_name, stat_name.capitalize()))

func get_stat_description(stat_name: String) -> String:
    return str(STAT_DESCRIPTIONS.get(stat_name, ""))

func get_allocated_points(stat_name: String) -> int:
    return maxi(0, int(_allocated_stats.get(stat_name, 0)))

func get_total_allocated_points() -> int:
    var total := 0
    for stat_name in ALLOCATABLE_STATS:
        total += get_allocated_points(stat_name)
    return total

func get_total_earned_points() -> int:
    return maxi(0, GameManager.job_level - 1) * POINTS_PER_JOB_LEVEL

func get_unspent_points() -> int:
    return maxi(0, get_total_earned_points() - get_total_allocated_points())

func can_allocate(stat_name: String) -> bool:
    return ALLOCATABLE_STATS.has(stat_name) and get_unspent_points() > 0 and get_allocated_points(stat_name) < MAX_ALLOCATION_PER_STAT

func allocate_point(stat_name: String) -> Dictionary:
    if not ALLOCATABLE_STATS.has(stat_name):
        return {"ok": false, "message": "Atribut tidak dikenal."}
    if get_unspent_points() <= 0:
        return {"ok": false, "message": "Tidak ada poin atribut tersisa."}
    if get_allocated_points(stat_name) >= MAX_ALLOCATION_PER_STAT:
        return {"ok": false, "message": "Atribut sudah mencapai batas alokasi."}
    _allocated_stats[stat_name] = get_allocated_points(stat_name) + 1
    stats_changed.emit()
    if is_instance_valid(SaveManager):
        SaveManager.save_game()
    return {"ok": true, "message": "%s bertambah 1 poin." % get_stat_label(stat_name)}

func get_save_data() -> Dictionary:
    return {"allocated_stats": _allocated_stats.duplicate(true)}

func load_save_data(data: Dictionary) -> void:
    var raw_allocations = data.get("allocated_stats", {})
    var clean := {
        "strength": 0,
        "vitality": 0,
        "defense": 0,
        "agility": 0,
        "ability": 0,
        "stamina": 0
    }
    var remaining := get_total_earned_points()
    if typeof(raw_allocations) == TYPE_DICTIONARY:
        for stat_name in ALLOCATABLE_STATS:
            var raw_value = raw_allocations.get(stat_name, 0)
            var requested := 0
            if typeof(raw_value) == TYPE_INT or typeof(raw_value) == TYPE_FLOAT:
                requested = clampi(int(raw_value), 0, MAX_ALLOCATION_PER_STAT)
            var accepted := mini(requested, remaining)
            clean[stat_name] = accepted
            remaining -= accepted
    _allocated_stats = clean
    stats_changed.emit()
