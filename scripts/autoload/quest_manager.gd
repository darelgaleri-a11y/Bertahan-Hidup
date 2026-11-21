extends Node

signal quests_changed

const QUESTS := {
    "first_harvest": {
        "title": "Panen Pertama",
        "description": "Panen ikan dari kolam sebanyak 1 kali.",
        "event": "harvest",
        "target_id": "",
        "target": 1,
        "reward": 100
    },
    "slime_hunter": {
        "title": "Pemburu Slime",
        "description": "Kalahkan Slime sebanyak 3 kali.",
        "event": "monster_kill",
        "target_id": "slime",
        "target": 3,
        "reward": 150
    },
    "gel_collector": {
        "title": "Pengumpul Gel",
        "description": "Kumpulkan 5 Slime Gel ke inventory.",
        "event": "collect_item",
        "target_id": "slime_gel",
        "target": 5,
        "reward": 125
    }
}

var progress: Dictionary = {}
var completed: Dictionary = {}
var claimed: Dictionary = {}
var initialized: bool = false

func _ready() -> void:
    initialize_if_needed()

func initialize_if_needed() -> void:
    if initialized:
        return
    initialized = true
    for quest_id in QUESTS.keys():
        progress[quest_id] = 0
        completed[quest_id] = false
        claimed[quest_id] = false

func record_event(event_type: String, target_id: String = "", amount: int = 1) -> void:
    initialize_if_needed()
    if amount <= 0:
        return
    var changed := false
    for quest_id_value in QUESTS.keys():
        var quest_id := str(quest_id_value)
        var data: Dictionary = QUESTS[quest_id]
        if bool(completed.get(quest_id, false)) or bool(claimed.get(quest_id, false)):
            continue
        if str(data.get("event", "")) != event_type:
            continue
        if str(data.get("target_id", "")) != target_id:
            continue
        var target := maxi(1, int(data.get("target", 1)))
        var old_value := int(progress.get(quest_id, 0))
        var new_value := mini(target, old_value + amount)
        if new_value != old_value:
            progress[quest_id] = new_value
            changed = true
        if new_value >= target:
            completed[quest_id] = true
            GameManager.notification_requested.emit("Misi selesai: %s. Ambil hadiah di Papan Misi." % str(data.get("title", quest_id)))
    if changed:
        quests_changed.emit()

func claim_reward(quest_id: String) -> Dictionary:
    initialize_if_needed()
    if not QUESTS.has(quest_id):
        return {"ok": false, "message": "Misi tidak ditemukan."}
    if not bool(completed.get(quest_id, false)):
        return {"ok": false, "message": "Misi belum selesai."}
    if bool(claimed.get(quest_id, false)):
        return {"ok": false, "message": "Hadiah misi ini sudah diambil."}
    var reward := maxi(0, int(QUESTS[quest_id].get("reward", 0)))
    claimed[quest_id] = true
    GameManager.add_money(reward)
    quests_changed.emit()
    return {"ok": true, "message": "Hadiah diterima: +%d Money." % reward}

func get_quest_status(quest_id: String) -> Dictionary:
    if not QUESTS.has(quest_id):
        return {}
    var data: Dictionary = QUESTS[quest_id].duplicate(true)
    data["progress"] = int(progress.get(quest_id, 0))
    data["completed"] = bool(completed.get(quest_id, false))
    data["claimed"] = bool(claimed.get(quest_id, false))
    return data

func get_save_data() -> Dictionary:
    return {
        "initialized": initialized,
        "progress": progress.duplicate(true),
        "completed": completed.duplicate(true),
        "claimed": claimed.duplicate(true)
    }

func load_save_data(data: Dictionary) -> void:
    initialized = true
    progress.clear()
    completed.clear()
    claimed.clear()
    var saved_progress = data.get("progress", {})
    var saved_completed = data.get("completed", {})
    var saved_claimed = data.get("claimed", {})
    for quest_id_value in QUESTS.keys():
        var quest_id := str(quest_id_value)
        var target := maxi(1, int(QUESTS[quest_id].get("target", 1)))
        progress[quest_id] = clampi(int(saved_progress.get(quest_id, 0)), 0, target) if typeof(saved_progress) == TYPE_DICTIONARY else 0
        completed[quest_id] = bool(saved_completed.get(quest_id, false)) if typeof(saved_completed) == TYPE_DICTIONARY else progress[quest_id] >= target
        claimed[quest_id] = bool(saved_claimed.get(quest_id, false)) if typeof(saved_claimed) == TYPE_DICTIONARY else false
        if progress[quest_id] >= target or claimed[quest_id]:
            completed[quest_id] = true
    quests_changed.emit()
