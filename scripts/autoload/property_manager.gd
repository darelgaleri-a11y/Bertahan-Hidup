extends Node

signal property_changed
signal relocation_started(land_id: String)
signal relocation_completed(land_id: String)

const CATALOG_PATH := "res://data/land_catalog.json"
var land_catalog: Dictionary = {}
var land_records: Dictionary = {}
var current_land_id: String = "village"
var initialized: bool = false

func _ready() -> void:
    _load_catalog()

func _load_catalog() -> void:
    if not FileAccess.file_exists(CATALOG_PATH):
        push_error("Katalog lahan tidak ditemukan.")
        return
    var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
    if file == null:
        push_error("Katalog lahan gagal dibuka.")
        return
    var parsed = JSON.parse_string(file.get_as_text())
    file.close()
    if typeof(parsed) == TYPE_DICTIONARY:
        land_catalog = parsed
    else:
        push_error("Format katalog lahan tidak valid.")

func initialize_if_needed() -> void:
    if initialized:
        return
    initialized = true
    var now := int(Time.get_unix_time_from_system())
    land_records = {
        "village": {
            "status": "rented",
            "rent_end_unix": now + 7 * 86400,
            "ever_unlocked": true
        },
        "forest": {"status": "locked", "rent_end_unix": 0, "ever_unlocked": false},
        "lakeside": {"status": "locked", "rent_end_unix": 0, "ever_unlocked": false}
    }
    current_land_id = "village"

func get_land_data(land_id: String) -> Dictionary:
    return land_catalog.get(land_id, {})

func get_land_record(land_id: String) -> Dictionary:
    return land_records.get(land_id, {})

func get_land_status(land_id: String) -> String:
    var record: Dictionary = land_records.get(land_id, {})
    var status := str(record.get("status", "locked"))
    if status == "rented" and int(record.get("rent_end_unix", 0)) <= int(Time.get_unix_time_from_system()):
        status = "expired"
    return status

func get_remaining_rent_days(land_id: String) -> int:
    var record: Dictionary = land_records.get(land_id, {})
    var seconds_left := int(record.get("rent_end_unix", 0)) - int(Time.get_unix_time_from_system())
    return maxi(0, int(ceil(float(seconds_left) / 86400.0)))

func can_access(land_id: String) -> bool:
    var data := get_land_data(land_id)
    if data.is_empty() or GameManager.job_level < int(data.get("min_job_level", 1)):
        return false
    var status := get_land_status(land_id)
    return status == "owned" or (status == "rented" and get_remaining_rent_days(land_id) > 0)

func rent_land(land_id: String) -> Dictionary:
    var data := get_land_data(land_id)
    if data.is_empty():
        return {"ok": false, "message": "Lahan tidak ditemukan."}
    if GameManager.job_level < int(data.get("min_job_level", 1)):
        return {"ok": false, "message": "Job Level belum memenuhi syarat lahan ini."}
    if get_land_status(land_id) == "owned":
        return {"ok": false, "message": "Lahan ini sudah menjadi milikmu."}
    var fee := int(data.get("rent_price", 0))
    if not GameManager.spend_money(fee):
        return {"ok": false, "message": "Money tidak cukup untuk menyewa lahan."}
    var now := int(Time.get_unix_time_from_system())
    var old_end := int(land_records.get(land_id, {}).get("rent_end_unix", 0))
    var base_time := maxi(now, old_end)
    land_records[land_id] = {
        "status": "rented",
        "rent_end_unix": base_time + int(data.get("rent_days", 7)) * 86400,
        "ever_unlocked": true
    }
    property_changed.emit()
    return {"ok": true, "message": "%s berhasil disewa selama %d hari." % [str(data.get("name", land_id)), int(data.get("rent_days", 7))]}

func buy_land(land_id: String) -> Dictionary:
    var data := get_land_data(land_id)
    if data.is_empty():
        return {"ok": false, "message": "Lahan tidak ditemukan."}
    if GameManager.job_level < int(data.get("min_job_level", 1)):
        return {"ok": false, "message": "Job Level belum memenuhi syarat lahan ini."}
    if get_land_status(land_id) == "owned":
        return {"ok": false, "message": "Lahan ini sudah kamu miliki."}
    var price := int(data.get("buy_price", 0))
    if not GameManager.spend_money(price):
        return {"ok": false, "message": "Money tidak cukup untuk membeli lahan."}
    land_records[land_id] = {
        "status": "owned",
        "rent_end_unix": 0,
        "ever_unlocked": true
    }
    property_changed.emit()
    return {"ok": true, "message": "%s sekarang menjadi milik permanenmu." % str(data.get("name", land_id))}

func relocate_to(land_id: String) -> Dictionary:
    if not land_catalog.has(land_id):
        return {"ok": false, "message": "Lahan tidak ditemukan."}
    if not can_access(land_id):
        return {"ok": false, "message": "Lahan belum aktif. Sewa atau beli terlebih dahulu."}
    if current_land_id == land_id:
        return {"ok": false, "message": "Kamu sudah berada di lahan ini."}
    current_land_id = land_id
    property_changed.emit()
    relocation_started.emit(land_id)
    return {"ok": true, "message": "NPC sedang memindahkan barang-barangmu ke %s." % str(get_land_data(land_id).get("name", land_id))}

func get_current_land_name() -> String:
    return str(get_land_data(current_land_id).get("name", "Lahan"))

func get_save_data() -> Dictionary:
    return {
        "initialized": initialized,
        "current_land_id": current_land_id,
        "land_records": land_records
    }

func load_save_data(data: Dictionary) -> void:
    initialized = bool(data.get("initialized", false))
    if not initialized:
        initialize_if_needed()
        return
    var records = data.get("land_records", {})
    land_records = records if typeof(records) == TYPE_DICTIONARY else {}
    for land_id in land_catalog.keys():
        if not land_records.has(land_id):
            land_records[land_id] = {"status": "locked", "rent_end_unix": 0, "ever_unlocked": false}
    var saved_current := str(data.get("current_land_id", "village"))
    current_land_id = saved_current if land_catalog.has(saved_current) else "village"
    if not can_access(current_land_id):
        current_land_id = "village"
    property_changed.emit()
