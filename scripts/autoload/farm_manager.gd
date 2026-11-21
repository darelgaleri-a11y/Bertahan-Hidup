extends Node

signal pond_changed

var fish_count: int = 0
var feed_count: int = 0
var growth_progress: float = 0.0
var last_update_unix: int = 0
var fish_ready: bool = false

# Satu unit pakan menopang ikan selama 24 jam.
# Nilai detik disimpan agar progres parsial tidak hilang saat game ditutup.
var feed_seconds_remaining: float = 0.0

const GROWTH_SECONDS := 48.0 * 3600.0
const FEED_SECONDS_PER_UNIT := 24.0 * 3600.0

func initialize_if_needed() -> void:
    if last_update_unix <= 0:
        last_update_unix = int(Time.get_unix_time_from_system())

func add_fish() -> bool:
    if fish_count >= 10:
        return false
    if not InventoryManager.remove_item("seed_basic", 1):
        return false

    fish_count += 1
    if feed_seconds_remaining <= 0.0:
        feed_seconds_remaining = FEED_SECONDS_PER_UNIT
    _sync_feed_count()
    last_update_unix = int(Time.get_unix_time_from_system())
    pond_changed.emit()
    return true

func add_feed() -> bool:
    if not InventoryManager.remove_item("feed_basic", 1):
        return false

    feed_seconds_remaining += 10.0 * FEED_SECONDS_PER_UNIT
    _sync_feed_count()
    pond_changed.emit()
    return true

func update_offline() -> void:
    initialize_if_needed()

    var now := int(Time.get_unix_time_from_system())
    var elapsed := max(0, now - last_update_unix)

    if fish_count > 0 and not fish_ready and elapsed > 0:
        # Pertumbuhan hanya berlangsung selama persediaan pakan tersedia.
        var active_seconds := min(float(elapsed), feed_seconds_remaining)
        if active_seconds > 0.0:
            growth_progress = min(1.0, growth_progress + active_seconds / GROWTH_SECONDS)
            feed_seconds_remaining = max(0.0, feed_seconds_remaining - active_seconds)

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
    feed_seconds_remaining = 0.0
    feed_count = 0

    GameManager.add_farm_value(10 * amount)
    InventoryManager.add_item("fish_basic", amount)
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
    fish_count = clampi(int(data.get("fish_count", 0)), 0, 10)
    growth_progress = clampf(float(data.get("growth_progress", 0.0)), 0.0, 1.0)
    last_update_unix = int(data.get("last_update_unix", 0))
    fish_ready = bool(data.get("fish_ready", false))

    # Kompatibilitas: save versi lama hanya memiliki feed_count.
    if data.has("feed_seconds_remaining"):
        feed_seconds_remaining = max(0.0, float(data.get("feed_seconds_remaining", 0.0)))
    else:
        feed_seconds_remaining = max(0.0, float(data.get("feed_count", 0)) * FEED_SECONDS_PER_UNIT)

    _sync_feed_count()
    initialize_if_needed()
    update_offline()

func _sync_feed_count() -> void:
    if feed_seconds_remaining <= 0.0:
        feed_count = 0
    else:
        feed_count = int(ceil(feed_seconds_remaining / FEED_SECONDS_PER_UNIT))
