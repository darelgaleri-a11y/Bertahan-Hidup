extends Node

signal pond_changed
var fish_count: int = 0
var feed_count: int = 0
var growth_progress: float = 0.0
var last_update_unix: int = 0
var fish_ready: bool = false

const GROWTH_SECONDS := 48.0 * 3600.0

func initialize_if_needed() -> void:
    if last_update_unix == 0:
        last_update_unix = int(Time.get_unix_time_from_system())

func add_fish() -> bool:
    if fish_count >= 10:
        return false
    if not InventoryManager.remove_item("seed_basic", 1):
        return false
    fish_count += 1
    feed_count = max(feed_count, 1)
    last_update_unix = int(Time.get_unix_time_from_system())
    pond_changed.emit()
    return true

func add_feed() -> bool:
    if not InventoryManager.remove_item("feed_basic", 1):
        return false
    feed_count += 10
    pond_changed.emit()
    return true

func update_offline() -> void:
    initialize_if_needed()
    var now := int(Time.get_unix_time_from_system())
    var elapsed := max(0, now - last_update_unix)
    if fish_count > 0 and feed_count > 0 and not fish_ready:
        var consumed := int(floor(float(elapsed) / 86400.0))
        var available_days := min(consumed, feed_count)
        growth_progress += float(available_days * 86400) / GROWTH_SECONDS
        feed_count -= available_days
        fish_ready = growth_progress >= 1.0
    last_update_unix = now
    pond_changed.emit()

func harvest() -> bool:
    if not fish_ready or fish_count <= 0:
        return false
    var amount := fish_count
    fish_count = 0
    fish_ready = false
    growth_progress = 0.0
    GameManager.add_farm_value(10 * amount)
    InventoryManager.add_item("fish_basic", amount)
    pond_changed.emit()
    return true

func get_save_data() -> Dictionary:
    return {"fish_count": fish_count, "feed_count": feed_count,
        "growth_progress": growth_progress, "last_update_unix": last_update_unix,
        "fish_ready": fish_ready}

func load_save_data(data: Dictionary) -> void:
    fish_count = int(data.get("fish_count", 0))
    feed_count = int(data.get("feed_count", 0))
    growth_progress = float(data.get("growth_progress", 0.0))
    last_update_unix = int(data.get("last_update_unix", 0))
    fish_ready = bool(data.get("fish_ready", false))
    update_offline()
