extends Node

const SAVE_PATH := "user://savegame.json"
const BACKUP_PATH := "user://savegame_backup.json"

func save_game() -> bool:
    var payload := {
        "version": 1,
        "saved_at": int(Time.get_unix_time_from_system()),
        "money": GameManager.money,
        "farm_value": GameManager.farm_value,
        "job_level": GameManager.job_level,
        "inventory": InventoryManager.items,
        "pond": FarmManager.get_save_data()
    }
    var file := FileAccess.open(SAVE_PATH + ".tmp", FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(payload))
    file.close()
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.copy_absolute(ProjectSettings.globalize_path(SAVE_PATH), ProjectSettings.globalize_path(BACKUP_PATH))
    var err := DirAccess.rename_absolute(ProjectSettings.globalize_path(SAVE_PATH + ".tmp"), ProjectSettings.globalize_path(SAVE_PATH))
    return err == OK

func load_game() -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        return false
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return false
    var parsed = JSON.parse_string(file.get_as_text())
    file.close()
    if typeof(parsed) != TYPE_DICTIONARY:
        return false
    GameManager.money = int(parsed.get("money", 250))
    GameManager.farm_value = int(parsed.get("farm_value", 0))
    GameManager.job_level = int(parsed.get("job_level", 1))
    InventoryManager.items = parsed.get("inventory", {})
    FarmManager.load_save_data(parsed.get("pond", {}))
    return true
