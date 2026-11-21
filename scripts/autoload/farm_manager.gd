extends Node

signal pond_changed

var fish_count: int = 0
var feed_count: int = 0
var growth_progress: float = 0.0
var last_update_unix: int = 0
var fish_ready: bool = false
var feed_seconds_remaining: float = 0.0

const GROWTH_SECONDS := 48.0 * 3600.0
const FEED_SECONDS_PER_UNIT := 24.0 * 3600.0
const MAX_FISH := 10

func initialize_if_needed() -> void:
    if last_update_unix <= 0:
        last_update_unix = int(Time.get_unix_time_from_system())

func add_fish() -> bool:
    update_offline()
    if fish_count >= MAX_FISH:
        return false
    if not InventoryManager.remove_item("seed_basic", 1):
        return false

    # Bibit tidak lagi memberikan pakan gratis setiap kali ditebar.
    # Pakan harus berasal dari inventory agar tidak bisa dieksploitasi.
    fish_count += 1
    last_update_unix = int(Time.get_unix_time_from_system())
    pond_changed.emit()
    return true

func add_feed() -> bool:
    update_offline()
    if not InventoryManager.remove_item("feed_basic", 1):
        return false
    feed_seconds_remaining += 10.0 * FEED_SECONDS_PER_UNIT
    _sync_feed_count()
    last_update_unix = int(Time.get_unix_time_from_system())
    pond_changed.emit()
    return true

func update_offline() -> void:
    initialize_if_needed()
    var now := int(Time.get_unix_time_from_system())
    var elapsed := maxf(0.0, float(now - last_update_unix))

    if fish_count > 0 and not fish_ready and elapsed > 0.0:
        var seconds_to_finish := maxf(0.0, (1.0 - growth_progress) * GROWTH_SECONDS)
        var active_seconds := minf(elapsed, minf(feed_seconds_remaining, seconds_to_finish))
        if active_seconds > 0.0:
            growth_progress = clampf(growth_progress + active_seconds / GROWTH_SECONDS, 0.0, 1.0)
            feed_seconds_remaining = maxf(0.0, feed_seconds_remaining - active_seconds)
        if growth_progress >= 1.0:
            growth_progress = 1.0
            fish_ready = true
        _sync_feed_count()

    last_update_unix = now
    pond_changed.emit()

func harvest() -> bool:
    if not fish_ready or fish_count <= 0:
        return false

    var amount := fish_count
    fish_count = 0
    fish_ready = false
    growth_progress = 0.0
    # Sisa pakan dipertahankan untuk siklus ikan berikutnya.

    GameManager.add_farm_value(10 * amount)
    InventoryManager.add_item("fish_basic", amount)
    last_update_unix = int(Time.get_unix_time_from_system())
    pond_changed.emit()
    return true

func get_save_data() -> Dictionary:
    return {
        "fish_count": fish_count,
        "feed_count": feed_count,
        "feed_seconds_remaining": feed_seconds_remaining,
        "growth_progress": growth_progress,
        "last_update_unix": last_update_unix,
        "fish_ready": fish_ready
    }

func load_save_data(data: Dictionary) -> void:
    fish_count = clampi(int(data.get("fish_count", 0)), 0, MAX_FISH)
    growth_progress = clampf(float(data.get("growth_progress", 0.0)), 0.0, 1.0)
    last_update_unix = int(data.get("last_update_unix", 0))
    fish_ready = bool(data.get("fish_ready", false))

    if data.has("feed_seconds_remaining"):
        feed_seconds_remaining = maxf(0.0, float(data.get("feed_seconds_remaining", 0.0)))
    else:
        # Kompatibel dengan save lama yang hanya menyimpan feed_count.
        feed_seconds_remaining = maxf(0.0, float(data.get("feed_count", 0)) * FEED_SECONDS_PER_UNIT)

    if fish_count <= 0:
        fish_ready = false
        growth_progress = 0.0
        feed_seconds_remaining = 0.0
    elif fish_ready:
        growth_progress = 1.0

    _sync_feed_count()
    initialize_if_needed()
    update_offline()

func _sync_feed_count() -> void:
    feed_seconds_remaining = maxf(0.0, feed_seconds_remaining)
    feed_count = int(ceil(feed_seconds_remaining / FEED_SECONDS_PER_UNIT)) if feed_seconds_remaining > 0.0 else 0
