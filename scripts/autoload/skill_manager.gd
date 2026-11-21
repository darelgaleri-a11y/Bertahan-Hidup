extends Node

signal skills_changed
signal stamina_changed(current: float, maximum: float)

const MAX_SKILL_LEVEL := 5
const USES_PER_LEVEL := 5
const SKILLS := {
    "power_strike": {
        "name": "Power Strike",
        "description": "Serangan kuat yang menghasilkan damage tambahan.",
        "unlock_level": 1,
        "stamina_cost": 20.0,
        "cooldown": 3.0
    },
    "recovery": {
        "name": "Recovery",
        "description": "Memulihkan HP pemain.",
        "unlock_level": 2,
        "stamina_cost": 30.0,
        "cooldown": 15.0
    }
}

var stamina: float = 100.0
var _last_max_stamina: float = 100.0
var _cooldowns: Dictionary = {"power_strike": 0.0, "recovery": 0.0}
var _skill_progress: Dictionary = {
    "power_strike": {"level": 1, "uses": 0},
    "recovery": {"level": 1, "uses": 0}
}

func _ready() -> void:
    _last_max_stamina = get_max_stamina()
    stamina = _last_max_stamina
    StatsManager.stats_changed.connect(_on_stats_changed)

func _on_stats_changed() -> void:
    var new_max := get_max_stamina()
    var increase := maxf(0.0, new_max - _last_max_stamina)
    stamina = minf(new_max, stamina + increase)
    _last_max_stamina = new_max
    stamina_changed.emit(stamina, new_max)

func _process(delta: float) -> void:
    for skill_id in _cooldowns.keys():
        _cooldowns[skill_id] = maxf(0.0, float(_cooldowns[skill_id]) - delta)
    var maximum := get_max_stamina()
    var previous := stamina
    stamina = minf(maximum, stamina + get_stamina_regen() * delta)
    if not is_equal_approx(previous, stamina):
        stamina_changed.emit(stamina, maximum)

func get_max_stamina() -> float:
    return float(StatsManager.get_stat("stamina")) * 10.0

func get_stamina_regen() -> float:
    return 2.0 + float(StatsManager.get_stat("ability")) * 0.1

func get_stamina() -> float:
    return stamina

func get_skill_level(skill_id: String) -> int:
    var data: Dictionary = _skill_progress.get(skill_id, {})
    return clampi(int(data.get("level", 1)), 1, MAX_SKILL_LEVEL)

func get_skill_uses(skill_id: String) -> int:
    var data: Dictionary = _skill_progress.get(skill_id, {})
    return maxi(0, int(data.get("uses", 0)))

func is_unlocked(skill_id: String) -> bool:
    if not SKILLS.has(skill_id):
        return false
    return GameManager.job_level >= int(SKILLS[skill_id].get("unlock_level", 99))

func get_cooldown(skill_id: String) -> float:
    return maxf(0.0, float(_cooldowns.get(skill_id, 0.0)))

func get_skill_status(skill_id: String) -> Dictionary:
    if not SKILLS.has(skill_id):
        return {}
    var info: Dictionary = SKILLS[skill_id]
    return {
        "name": str(info["name"]),
        "description": str(info["description"]),
        "level": get_skill_level(skill_id),
        "uses": get_skill_uses(skill_id),
        "unlocked": is_unlocked(skill_id),
        "cooldown": get_cooldown(skill_id),
        "stamina_cost": float(info["stamina_cost"])
    }

func cast_skill(skill_id: String, player: Node, target: Node = null) -> Dictionary:
    if not SKILLS.has(skill_id):
        return {"ok": false, "message": "Skill tidak ditemukan."}
    if not is_instance_valid(player) or bool(player.get("is_defeated")):
        return {"ok": false, "message": "Pemain tidak dapat menggunakan skill sekarang."}
    if not is_unlocked(skill_id):
        return {"ok": false, "message": "Skill belum terbuka. Naikkan Job Level terlebih dahulu."}
    if get_cooldown(skill_id) > 0.0:
        return {"ok": false, "message": "Skill masih cooldown %.1f detik." % get_cooldown(skill_id)}

    var info: Dictionary = SKILLS[skill_id]
    var cost := float(info["stamina_cost"])
    if stamina < cost:
        return {"ok": false, "message": "Stamina tidak cukup."}

    var level := get_skill_level(skill_id)
    var ability_bonus := StatsManager.get_stat("ability") - 5
    var result_message := ""
    if skill_id == "power_strike":
        if not is_instance_valid(target) or not target.has_method("take_damage"):
            return {"ok": false, "message": "Tidak ada monster dalam jangkauan skill."}
        var base_damage := int(player.call("get_attack_damage"))
        var damage := maxi(1, int(round(float(base_damage) * (1.5 + float(level - 1) * 0.15) + float(ability_bonus))))
        target.take_damage(damage)
        result_message = "Power Strike! %d damage." % damage
    elif skill_id == "recovery":
        if not player.has_method("heal"):
            return {"ok": false, "message": "Sistem pemulihan pemain belum tersedia."}
        var healing := 25 + level * 5 + ability_bonus * 2
        var restored := int(player.call("heal", healing))
        if restored <= 0:
            return {"ok": false, "message": "HP sudah penuh."}
        result_message = "Recovery memulihkan %d HP." % restored

    stamina = maxf(0.0, stamina - cost)
    _cooldowns[skill_id] = float(info["cooldown"])
    _record_skill_use(skill_id)
    stamina_changed.emit(stamina, get_max_stamina())
    skills_changed.emit()
    return {"ok": true, "message": result_message}

func _record_skill_use(skill_id: String) -> void:
    var data: Dictionary = _skill_progress.get(skill_id, {"level": 1, "uses": 0})
    data["uses"] = maxi(0, int(data.get("uses", 0))) + 1
    var new_level := mini(MAX_SKILL_LEVEL, 1 + int(data["uses"]) / USES_PER_LEVEL)
    var level_changed := new_level > int(data.get("level", 1))
    data["level"] = new_level
    _skill_progress[skill_id] = data
    if level_changed:
        GameManager.notification_requested.emit("%s naik ke Level %d!" % [str(SKILLS[skill_id]["name"]), new_level])

func restore_stamina(amount: float) -> void:
    if amount <= 0.0:
        return
    stamina = minf(get_max_stamina(), stamina + amount)
    stamina_changed.emit(stamina, get_max_stamina())

func get_save_data() -> Dictionary:
    return {
        "stamina": stamina,
        "skill_progress": _skill_progress.duplicate(true)
    }

func load_save_data(data: Dictionary) -> void:
    var maximum := get_max_stamina()
    var raw_stamina = data.get("stamina", maximum)
    if typeof(raw_stamina) == TYPE_INT or typeof(raw_stamina) == TYPE_FLOAT:
        stamina = clampf(float(raw_stamina), 0.0, maximum)
    else:
        stamina = maximum

    var raw_progress = data.get("skill_progress", {})
    var clean: Dictionary = {}
    if typeof(raw_progress) == TYPE_DICTIONARY:
        for skill_id in SKILLS.keys():
            var raw_entry = raw_progress.get(skill_id, {})
            if typeof(raw_entry) != TYPE_DICTIONARY:
                raw_entry = {}
            var uses := clampi(int(raw_entry.get("uses", 0)), 0, 100000)
            var level := clampi(int(raw_entry.get("level", 1)), 1, MAX_SKILL_LEVEL)
            # Rekonsiliasi level berdasarkan penggunaan agar save yang tidak konsisten tidak memberi level palsu.
            level = mini(level, mini(MAX_SKILL_LEVEL, 1 + int(uses / USES_PER_LEVEL)))
            clean[skill_id] = {"level": level, "uses": uses}
    else:
        for skill_id in SKILLS.keys():
            clean[skill_id] = {"level": 1, "uses": 0}
    _skill_progress = clean
    _cooldowns = {"power_strike": 0.0, "recovery": 0.0}
    _last_max_stamina = maximum
    stamina_changed.emit(stamina, get_max_stamina())
    skills_changed.emit()
