extends Node

signal skills_changed
signal stamina_changed(current: float, maximum: float)
signal specialization_changed(skill_id: String, specialization_id: String)

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
const SPECIALIZATIONS := {
    "power_strike": {
        "berserker": {"name": "Berserker", "description": "Damage Power Strike meningkat 25%.", "damage_multiplier": 1.25},
        "focused": {"name": "Focused", "description": "Biaya stamina Power Strike berkurang 25%.", "stamina_multiplier": 0.75}
    },
    "recovery": {
        "renewal": {"name": "Renewal", "description": "Jumlah pemulihan Recovery meningkat 30%.", "healing_multiplier": 1.30},
        "efficient": {"name": "Efficient", "description": "Cooldown Recovery berkurang 25%.", "cooldown_multiplier": 0.75}
    }
}

var stamina: float = 100.0
var _last_max_stamina: float = 100.0
var _cooldowns: Dictionary = {"power_strike": 0.0, "recovery": 0.0}
var _skill_progress: Dictionary = {
    "power_strike": {"level": 1, "uses": 0},
    "recovery": {"level": 1, "uses": 0}
}
var _specializations: Dictionary = {"power_strike": "", "recovery": ""}
var _specialization_layer: CanvasLayer
var _specialization_panel: PanelContainer
var _specialization_content: VBoxContainer

func _ready() -> void:
    _last_max_stamina = get_max_stamina()
    stamina = _last_max_stamina
    StatsManager.stats_changed.connect(_on_stats_changed)
    _create_specialization_ui()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_N:
        _toggle_specialization_ui()
        get_viewport().set_input_as_handled()

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
    return 2.0 + float(StatsManager.get_stat("ability")) * 0.1 + SkillPassiveManager.get_stamina_regen_bonus()

func get_stamina() -> float:
    return stamina

func get_skill_level(skill_id: String) -> int:
    var data: Dictionary = _skill_progress.get(skill_id, {})
    return clampi(int(data.get("level", 1)), 1, MAX_SKILL_LEVEL)

func get_skill_uses(skill_id: String) -> int:
    var data: Dictionary = _skill_progress.get(skill_id, {})
    return maxi(0, int(data.get("uses", 0)))

func is_unlocked(skill_id: String) -> bool:
    return SKILLS.has(skill_id) and GameManager.job_level >= int(SKILLS[skill_id].get("unlock_level", 99))

func get_cooldown(skill_id: String) -> float:
    return maxf(0.0, float(_cooldowns.get(skill_id, 0.0)))

func get_specialization(skill_id: String) -> String:
    return str(_specializations.get(skill_id, ""))

func get_specialization_status(skill_id: String) -> Dictionary:
    if not SPECIALIZATIONS.has(skill_id):
        return {}
    var selected := get_specialization(skill_id)
    var options: Array[Dictionary] = []
    for specialization_id in SPECIALIZATIONS[skill_id]:
        var option: Dictionary = SPECIALIZATIONS[skill_id][specialization_id].duplicate(true)
        option["id"] = str(specialization_id)
        option["selected"] = str(specialization_id) == selected
        options.append(option)
    return {"selected": selected, "available": get_skill_level(skill_id) >= 2, "options": options}

func get_skill_status(skill_id: String) -> Dictionary:
    if not SKILLS.has(skill_id):
        return {}
    var info: Dictionary = SKILLS[skill_id]
    return {
        "name": str(info["name"]), "description": str(info["description"]),
        "level": get_skill_level(skill_id), "uses": get_skill_uses(skill_id),
        "unlocked": is_unlocked(skill_id), "cooldown": get_cooldown(skill_id),
        "stamina_cost": _get_effective_stamina_cost(skill_id),
        "specialization": get_specialization(skill_id)
    }

func _get_effective_stamina_cost(skill_id: String) -> float:
    var base_cost := float(SKILLS.get(skill_id, {}).get("stamina_cost", 0.0))
    var spec_id := get_specialization(skill_id)
    var spec: Dictionary = SPECIALIZATIONS.get(skill_id, {}).get(spec_id, {})
    return base_cost * float(spec.get("stamina_multiplier", 1.0))

func _get_effective_cooldown(skill_id: String) -> float:
    var base_cooldown := float(SKILLS.get(skill_id, {}).get("cooldown", 0.0))
    var spec_id := get_specialization(skill_id)
    var spec: Dictionary = SPECIALIZATIONS.get(skill_id, {}).get(spec_id, {})
    return base_cooldown * float(spec.get("cooldown_multiplier", 1.0))

func choose_specialization(skill_id: String, specialization_id: String) -> Dictionary:
    if not SPECIALIZATIONS.has(skill_id) or not SPECIALIZATIONS[skill_id].has(specialization_id):
        return {"ok": false, "message": "Spesialisasi tidak ditemukan."}
    if get_skill_level(skill_id) < 2:
        return {"ok": false, "message": "Skill harus mencapai Level 2 untuk memilih spesialisasi."}
    if get_specialization(skill_id) != "":
        return {"ok": false, "message": "Spesialisasi skill ini sudah dipilih dan tidak dapat diganti."}
    _specializations[skill_id] = specialization_id
    specialization_changed.emit(skill_id, specialization_id)
    skills_changed.emit()
    if is_instance_valid(SaveManager):
        SaveManager.save_game()
    var selected: Dictionary = SPECIALIZATIONS[skill_id][specialization_id]
    GameManager.notification_requested.emit("%s: spesialisasi %s dipilih." % [str(SKILLS[skill_id]["name"]), str(selected["name"])])
    _refresh_specialization_ui()
    return {"ok": true, "message": "Spesialisasi %s berhasil dipilih." % str(selected["name"])}

func cast_skill(skill_id: String, player: Node, target: Node = null) -> Dictionary:
    if not SKILLS.has(skill_id):
        return {"ok": false, "message": "Skill tidak ditemukan."}
    if not is_instance_valid(player) or bool(player.get("is_defeated")):
        return {"ok": false, "message": "Pemain tidak dapat menggunakan skill sekarang."}
    if not is_unlocked(skill_id):
        return {"ok": false, "message": "Skill belum terbuka. Naikkan Job Level terlebih dahulu."}
    if get_cooldown(skill_id) > 0.0:
        return {"ok": false, "message": "Skill masih cooldown %.1f detik." % get_cooldown(skill_id)}
    var cost := _get_effective_stamina_cost(skill_id)
    if stamina < cost:
        return {"ok": false, "message": "Stamina tidak cukup."}
    var level := get_skill_level(skill_id)
    var ability_bonus := StatsManager.get_stat("ability") - 5
    var specialization_id := get_specialization(skill_id)
    var specialization: Dictionary = SPECIALIZATIONS.get(skill_id, {}).get(specialization_id, {})
    var result_message := ""
    if skill_id == "power_strike":
        if not is_instance_valid(target) or not target.has_method("take_damage"):
            return {"ok": false, "message": "Tidak ada monster dalam jangkauan skill."}
        var base_damage := int(player.call("get_attack_damage"))
        var level_multiplier := 1.5 + float(level - 1) * 0.15
        var damage_multiplier := float(specialization.get("damage_multiplier", 1.0))
        var damage := maxi(1, int(round(float(base_damage) * level_multiplier * damage_multiplier + float(ability_bonus))))
        target.take_damage(damage)
        result_message = "Power Strike! %d damage." % damage
    elif skill_id == "recovery":
        if not player.has_method("heal"):
            return {"ok": false, "message": "Sistem pemulihan pemain belum tersedia."}
        var healing_multiplier := float(specialization.get("healing_multiplier", 1.0))
        var healing := int(round(float(25 + level * 5 + ability_bonus * 2) * healing_multiplier))
        var restored := int(player.call("heal", healing))
        if restored <= 0:
            return {"ok": false, "message": "HP sudah penuh."}
        result_message = "Recovery memulihkan %d HP." % restored
    stamina = maxf(0.0, stamina - cost)
    _cooldowns[skill_id] = _get_effective_cooldown(skill_id)
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
        _refresh_specialization_ui()

func restore_stamina(amount: float) -> void:
    if amount <= 0.0:
        return
    stamina = minf(get_max_stamina(), stamina + amount)
    stamina_changed.emit(stamina, get_max_stamina())

func get_save_data() -> Dictionary:
    return {"stamina": stamina, "skill_progress": _skill_progress.duplicate(true), "specializations": _specializations.duplicate(true)}

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
            level = mini(level, mini(MAX_SKILL_LEVEL, 1 + int(uses / USES_PER_LEVEL)))
            clean[skill_id] = {"level": level, "uses": uses}
    else:
        for skill_id in SKILLS.keys():
            clean[skill_id] = {"level": 1, "uses": 0}
    _skill_progress = clean
    var raw_specializations = data.get("specializations", {})
    var clean_specializations := {"power_strike": "", "recovery": ""}
    if typeof(raw_specializations) == TYPE_DICTIONARY:
        for skill_id in SPECIALIZATIONS.keys():
            var candidate := str(raw_specializations.get(skill_id, ""))
            if SPECIALIZATIONS[skill_id].has(candidate) and get_skill_level(skill_id) >= 2:
                clean_specializations[skill_id] = candidate
    _specializations = clean_specializations
    _cooldowns = {"power_strike": 0.0, "recovery": 0.0}
    _last_max_stamina = maximum
    stamina_changed.emit(stamina, get_max_stamina())
    skills_changed.emit()
    _refresh_specialization_ui()

func _create_specialization_ui() -> void:
    _specialization_layer = CanvasLayer.new()
    _specialization_layer.name = "SkillSpecializationLayer"
    add_child(_specialization_layer)
    var touch_button := Button.new()
    touch_button.name = "SpecializationTouchButton"
    touch_button.text = "TALENTA"
    touch_button.position = Vector2(400, 420)
    touch_button.size = Vector2(100, 54)
    touch_button.visible = OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()
    touch_button.pressed.connect(_toggle_specialization_ui)
    _specialization_layer.add_child(touch_button)
    _specialization_panel = PanelContainer.new()
    _specialization_panel.name = "SpecializationPanel"
    _specialization_panel.position = Vector2(230, 75)
    _specialization_panel.size = Vector2(500, 380)
    _specialization_panel.custom_minimum_size = Vector2(500, 380)
    _specialization_panel.visible = false
    _specialization_layer.add_child(_specialization_panel)
    _specialization_content = VBoxContainer.new()
    _specialization_panel.add_child(_specialization_content)
    _refresh_specialization_ui()

func _toggle_specialization_ui() -> void:
    if not is_instance_valid(_specialization_panel):
        return
    _specialization_panel.visible = not _specialization_panel.visible
    if _specialization_panel.visible:
        _refresh_specialization_ui()

func _refresh_specialization_ui() -> void:
    if not is_instance_valid(_specialization_content):
        return
    for child in _specialization_content.get_children():
        _specialization_content.remove_child(child)
        child.free()
    var header := HBoxContainer.new()
    _specialization_content.add_child(header)
    var title := Label.new()
    title.text = "SPESIALISASI SKILL"
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)
    var close_button := Button.new()
    close_button.text = "TUTUP"
    close_button.pressed.connect(_toggle_specialization_ui)
    header.add_child(close_button)
    var intro := Label.new()
    intro.text = "Skill harus mencapai Level 2. Pilihan bersifat permanen."
    intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _specialization_content.add_child(intro)
    for skill_id in ["power_strike", "recovery"]:
        var row := VBoxContainer.new()
        _specialization_content.add_child(row)
        var skill_label := Label.new()
        skill_label.text = "%s — Level %d" % [str(SKILLS[skill_id]["name"]), get_skill_level(skill_id)]
        row.add_child(skill_label)
        var selected_id := get_specialization(skill_id)
        for specialization_id in SPECIALIZATIONS[skill_id]:
            var option: Dictionary = SPECIALIZATIONS[skill_id][specialization_id]
            var button := Button.new()
            button.text = "%s: %s" % [str(option["name"]), str(option["description"])]
            button.disabled = get_skill_level(skill_id) < 2 or selected_id != ""
            if selected_id == str(specialization_id):
                button.text = "DIPILIH — " + button.text
                button.disabled = true
            button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            button.pressed.connect(_on_specialization_button_pressed.bind(skill_id, str(specialization_id)))
            row.add_child(button)

func _on_specialization_button_pressed(skill_id: String, specialization_id: String) -> void:
    var result := choose_specialization(skill_id, specialization_id)
    GameManager.notification_requested.emit(str(result.get("message", "Spesialisasi diproses.")))
    _refresh_specialization_ui()
