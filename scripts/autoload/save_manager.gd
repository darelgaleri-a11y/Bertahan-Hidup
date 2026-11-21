extends Node

const SAVE_PATH := "user://savegame.json"
const TEMP_PATH := "user://savegame.json.tmp"
const BACKUP_PATH := "user://savegame_backup.json"

func save_game() -> bool:
    # Hitung pertumbuhan sampai detik penyimpanan agar tidak ada waktu yang hilang.
    FarmManager.update_offline()
    var payload := {
        "version": 2,
        "saved_at": int(Time.get_unix_time_from_system()),
        "money": GameManager.money,
        "farm_value": GameManager.farm_value,
        "job_level": GameManager.job_level,
        "inventory": InventoryManager.items,
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
            push_error("Gagal membuat backup save game.")
            DirAccess.remove_absolute(temp_absolute)
            return false

    if had_save:
        var remove_error := DirAccess.remove_absolute(save_absolute)
        if remove_error != OK:
            push_error("Gagal menyiapkan file save lama untuk diganti.")
            DirAccess.remove_absolute(temp_absolute)
            return false

    var replace_error := DirAccess.rename_absolute(temp_absolute, save_absolute)
    if replace_error != OK:
        push_error("Gagal mengganti file save. Mencoba memulihkan backup.")
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
    return parsed

func load_game() -> bool:
    var parsed := _read_save_file(SAVE_PATH)
    if parsed.is_empty() and FileAccess.file_exists(BACKUP_PATH):
        parsed = _read_save_file(BACKUP_PATH)
        if not parsed.is_empty():
            push_warning("Save utama tidak valid. Data dipulihkan dari backup.")
    if parsed.is_empty():
        return false

    GameManager.money = int(parsed.get("money", 250))
    GameManager.farm_value = int(parsed.get("farm_value", 0))
    GameManager.job_level = int(parsed.get("job_level", 1))
    var saved_inventory = parsed.get("inventory", {})
    if typeof(saved_inventory) == TYPE_DICTIONARY:
        InventoryManager.items = saved_inventory
    var saved_pond = parsed.get("pond", {})
    if typeof(saved_pond) == TYPE_DICTIONARY:
        FarmManager.load_save_data(saved_pond)

    GameManager.money_changed.emit(GameManager.money)
    GameManager.farm_value_changed.emit(GameManager.farm_value)
    InventoryManager.inventory_changed.emit()
    return true
