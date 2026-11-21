extends Node

const SAVE_PATH := "user://savegame.json"
const TEMP_PATH := "user://savegame.json.tmp"
const BACKUP_PATH := "user://savegame_backup.json"
const SAVE_VERSION := 6

func save_game() -> bool:
    FarmManager.update_offline()
    var payload := {
        "version": SAVE_VERSION,
        "saved_at": int(Time.get_unix_time_from_system()),
        "money": GameManager.money,
        "region": RegionManager.get_save_data(),
        "farm_value": GameManager.farm_value,
        "job_level": GameManager.job_level,
        "inventory": InventoryManager.items,
        "pending_loot": LootManager.get_save_data(),
        "property": PropertyManager.get_save_data(),
        "quests": QuestManager.get_save_data(),
        "equipment": EquipmentManager.get_save_data(),
        "skills": SkillManager.get_save_data(),
        "pond": FarmManager.get_save_data()
    }
    var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
    if file == null:
        push_error("Gagal membuka file sementara untuk menyimpan game.")
        return false
    file.store_string(JSON.stringify(payload))
    file.flush()
    var write_error := file.get_error()
    file.close()
    if write_error != OK:
        push_error("Gagal menulis data save game.")
        DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_PATH))
        return false

    var save_absolute := ProjectSettings.globalize_path(SAVE_PATH)
    var temp_absolute := ProjectSettings.globalize_path(TEMP_PATH)
    var backup_absolute := ProjectSettings.globalize_path(BACKUP_PATH)
    var had_save := FileAccess.file_exists(SAVE_PATH)
    if had_save:
        if FileAccess.file_exists(BACKUP_PATH):
            DirAccess.remove_absolute(backup_absolute)
        var backup_error := DirAccess.copy_absolute(save_absolute, backup_absolute)
        if backup_error != OK:
            push_error("Gagal membuat backup save game; save lama tidak diubah.")
            DirAccess.remove_absolute(temp_absolute)
            return false
        var remove_error := DirAccess.remove_absolute(save_absolute)
        if remove_error != OK:
            push_error("Gagal mengganti save lama; backup tetap tersedia.")
            DirAccess.remove_absolute(temp_absolute)
            return false

    var replace_error := DirAccess.rename_absolute(temp_absolute, save_absolute)
    if replace_error != OK:
        push_error("Gagal mengganti save. Mencoba memulihkan backup.")
        DirAccess.remove_absolute(temp_absolute)
        if had_save and FileAccess.file_exists(BACKUP_PATH):
            DirAccess.copy_absolute(backup_absolute, save_absolute)
        return false
    return true

func _read_save_file(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    file.close()
    if typeof(parsed) != TYPE_DICTIONARY:
        return {}
    if not parsed.has("money") or not parsed.has("inventory") or not parsed.has("pond"):
        return {}
    if typeof(parsed.get("inventory")) != TYPE_DICTIONARY or typeof(parsed.get("pond")) != TYPE_DICTIONARY:
        return {}
    var save_version = parsed.get("version", 1)
    if (typeof(save_version) != TYPE_INT and typeof(save_version) != TYPE_FLOAT):
        return {}
    if int(save_version) < 1 or int(save_version) > SAVE_VERSION:
        return {}
    var raw_money = parsed.get("money", null)
    if typeof(raw_money) != TYPE_INT and typeof(raw_money) != TYPE_FLOAT:
        return {}
    var raw_farm_value = parsed.get("farm_value", 0)
    if typeof(raw_farm_value) != TYPE_INT and typeof(raw_farm_value) != TYPE_FLOAT:
        return {}
    return parsed

func load_game() -> bool:
    var parsed := _read_save_file(SAVE_PATH)
    if parsed.is_empty() and FileAccess.file_exists(BACKUP_PATH):
        parsed = _read_save_file(BACKUP_PATH)
        if not parsed.is_empty():
            push_warning("Save utama tidak valid. Data dipulihkan dari backup.")
    if parsed.is_empty():
        return false

    GameManager.money = maxi(0, int(parsed.get("money", 250)))
    GameManager.farm_value = maxi(0, int(parsed.get("farm_value", 0)))
    GameManager.job_level = maxi(1, int(parsed.get("job_level", 1)))
    GameManager.recalculate_progression()
    var saved_region_value = parsed.get("region", {})
    var saved_region: Dictionary = saved_region_value if typeof(saved_region_value) == TYPE_DICTIONARY else {}
    RegionManager.load_save_data(saved_region)

    InventoryManager.items = {}
    var saved_inventory: Dictionary = parsed.get("inventory", {})
    for item_id in saved_inventory.keys():
        var raw_amount = saved_inventory[item_id]
        if typeof(raw_amount) == TYPE_INT or typeof(raw_amount) == TYPE_FLOAT:
            var amount := maxi(0, int(raw_amount))
            if amount > 0:
                InventoryManager.items[str(item_id)] = amount
    InventoryManager.sanitize_inventory()

    var saved_pond: Dictionary = parsed.get("pond", {})
    FarmManager.load_save_data(saved_pond)
    var saved_loot_value = parsed.get("pending_loot", {})
    var saved_loot: Dictionary = saved_loot_value if typeof(saved_loot_value) == TYPE_DICTIONARY else {}
    LootManager.load_save_data(saved_loot)
    var saved_property_value = parsed.get("property", {})
    var saved_property: Dictionary = saved_property_value if typeof(saved_property_value) == TYPE_DICTIONARY else {}
    PropertyManager.load_save_data(saved_property)
    var saved_quests_value = parsed.get("quests", {})
    var saved_quests: Dictionary = saved_quests_value if typeof(saved_quests_value) == TYPE_DICTIONARY else {}
    QuestManager.load_save_data(saved_quests)
    var saved_equipment_value = parsed.get("equipment", {})
    var saved_equipment: Dictionary = saved_equipment_value if typeof(saved_equipment_value) == TYPE_DICTIONARY else {}
    EquipmentManager.load_save_data(saved_equipment)
    var saved_skills_value = parsed.get("skills", {})
    var saved_skills: Dictionary = saved_skills_value if typeof(saved_skills_value) == TYPE_DICTIONARY else {}
    SkillManager.load_save_data(saved_skills)
    GameManager.money_changed.emit(GameManager.money)
    GameManager.farm_value_changed.emit(GameManager.farm_value)
    InventoryManager.inventory_changed.emit()
    return true
