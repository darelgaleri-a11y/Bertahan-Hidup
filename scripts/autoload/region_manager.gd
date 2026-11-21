extends Node

signal region_changed(region_id: String)

const CATALOG_PATH := "res://data/region_catalog.json"

var region_catalog: Dictionary = {}
var current_region_id: String = "village"

func _ready() -> void:
    _load_catalog()

func _load_catalog() -> void:
    if not FileAccess.file_exists(CATALOG_PATH):
        push_error("Katalog wilayah tidak ditemukan: " + CATALOG_PATH)
        return
    var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
    if file == null:
        push_error("Katalog wilayah tidak dapat dibuka.")
        return
    var parsed = JSON.parse_string(file.get_as_text())
    file.close()
    if typeof(parsed) == TYPE_DICTIONARY and parsed.has("village"):
        region_catalog = parsed
    else:
        push_error("Format katalog wilayah tidak valid atau tidak memiliki wilayah awal.")

func get_region_ids() -> Array[String]:
    var result: Array[String] = []
    for region_id in region_catalog.keys():
        result.append(str(region_id))
    return result

func get_region_data(region_id: String) -> Dictionary:
    var value = region_catalog.get(region_id, {})
    return value if typeof(value) == TYPE_DICTIONARY else {}

func get_current_region_data() -> Dictionary:
    return get_region_data(current_region_id)

func get_current_region_name() -> String:
    return str(get_current_region_data().get("name", "Desa"))

func get_spawn_position(region_id: String = "") -> Vector2:
    var selected_id := current_region_id if region_id.is_empty() else region_id
    var data := get_region_data(selected_id)
    var position_value = data.get("spawn_position", [380, 270])
    if typeof(position_value) != TYPE_ARRAY or position_value.size() < 2:
        return Vector2(380, 270)
    return Vector2(float(position_value[0]), float(position_value[1]))

func can_access(region_id: String) -> bool:
    var data := get_region_data(region_id)
    if data.is_empty():
        return false
    return GameManager.job_level >= maxi(1, int(data.get("min_job_level", 1)))

func travel_to(region_id: String) -> Dictionary:
    var data := get_region_data(region_id)
    if data.is_empty():
        return {"ok": false, "message": "Wilayah tidak ditemukan."}
    if not can_access(region_id):
        return {"ok": false, "message": "Wilayah terkunci. Butuh Job Level %d." % int(data.get("min_job_level", 1))}
    if current_region_id == region_id:
        return {"ok": false, "message": "Kamu sudah berada di wilayah ini."}
    current_region_id = region_id
    region_changed.emit(current_region_id)
    return {"ok": true, "message": "Berhasil memasuki wilayah %s." % str(data.get("name", region_id))}

func get_save_data() -> Dictionary:
    return {"current_region_id": current_region_id}

func load_save_data(data: Dictionary) -> void:
    var saved_region := str(data.get("current_region_id", "village"))
    if not region_catalog.has(saved_region) or not can_access(saved_region):
        saved_region = "village"
    current_region_id = saved_region
    region_changed.emit(current_region_id)
