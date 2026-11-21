extends CharacterBody2D

signal defeated(monster_id: String, monster_name: String, loot_summary: String, respawn_position: Vector2, scene_path: String)
signal health_changed(current: int, maximum: int)

@export var monster_id: String = "monster_slime"
@export var monster_name: String = "Slime"
@export var region_id: String = "village"
@export var required_job_level: int = 1
@export var max_health: int = 50
@export var attack_damage: int = 5
@export var defense: int = 0
@export var move_speed: float = 30.0
@export var detection_range: float = 180.0
@export var attack_range: float = 22.0
@export var attack_cooldown: float = 1.2
@export var loot_item: String = "slime_gel"
@export var material_drop_min: int = 1
@export var material_drop_max: int = 2
@export_range(0.0, 1.0) var seed_drop_chance: float = 0.10

var health: int = 0
var player: CharacterBody2D
var _attack_timer: float = 0.0
var _dead: bool = false
var _unlocked: bool = false
var _home_position: Vector2 = Vector2.ZERO

func _ready() -> void:
    health = maxi(1, max_health)
    _home_position = global_position
    # Semua monster didaftarkan agar sinyal defeated terhubung meskipun
    # monster sedang terkunci atau berada di wilayah lain.
    add_to_group("monster_entities")
    if not RegionManager.region_changed.is_connected(_on_region_changed):
        RegionManager.region_changed.connect(_on_region_changed)
    _unlocked = GameManager.job_level >= required_job_level
    _sync_region_presence()
    player = get_tree().get_first_node_in_group("player") as CharacterBody2D
    health_changed.emit(health, max_health)

func _process(_delta: float) -> void:
    if not _unlocked and GameManager.job_level >= required_job_level:
        _unlocked = true
        _sync_region_presence()
        var region_name := str(RegionManager.get_region_data(region_id).get("name", region_id))
        GameManager.notification_requested.emit("%s terbuka! Temukan di wilayah %s." % [monster_name, region_name])

func _on_region_changed(_new_region_id: String) -> void:
    _sync_region_presence()

func _sync_region_presence() -> void:
    _unlocked = GameManager.job_level >= required_job_level
    var is_active := _unlocked and region_id == RegionManager.current_region_id and not _dead
    visible = is_active
    collision_layer = 2 if is_active else 0
    collision_mask = 1 if is_active else 0
    set_physics_process(is_active)
    # _process tetap aktif untuk mendeteksi kenaikan Job Level ketika monster
    # berada di wilayah lain; hanya _physics_process yang mengikuti wilayah aktif.
    set_process(true)
    if is_active:
        if not is_in_group("monsters"):
            add_to_group("monsters")
    elif is_in_group("monsters"):
        remove_from_group("monsters")

func _physics_process(delta: float) -> void:
    if _dead or not _unlocked:
        return
    _attack_timer = maxf(0.0, _attack_timer - delta)
    if not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as CharacterBody2D
        velocity = Vector2.ZERO
        move_and_slide()
        return
    if bool(player.get("is_defeated")):
        velocity = Vector2.ZERO
        move_and_slide()
        return
    var distance := global_position.distance_to(player.global_position)
    var distance_from_home := global_position.distance_to(_home_position)
    var target_is_near := distance <= detection_range
    var has_room_to_chase := distance_from_home < detection_range
    if target_is_near and distance > attack_range and has_room_to_chase:
        velocity = global_position.direction_to(player.global_position) * move_speed
    else:
        velocity = Vector2.ZERO
        if distance <= attack_range and _attack_timer <= 0.0:
            if player.has_method("take_damage"):
                player.take_damage(attack_damage)
            _attack_timer = attack_cooldown
    move_and_slide()

func take_damage(amount: int) -> void:
    if _dead or not _unlocked or amount <= 0:
        return
    var actual_damage := maxi(1, amount - maxi(0, defense))
    health = maxi(0, health - actual_damage)
    health_changed.emit(health, max_health)
    if health <= 0:
        _die()

func _die() -> void:
    if _dead:
        return
    _dead = true
    velocity = Vector2.ZERO
    remove_from_group("monsters")
    var minimum_drop := mini(material_drop_min, material_drop_max)
    var maximum_drop := maxi(material_drop_min, material_drop_max)
    var material_amount := randi_range(maxi(1, minimum_drop), maxi(1, maximum_drop))
    var summary_parts := PackedStringArray()
    if InventoryManager.add_item(loot_item, material_amount):
        summary_parts.append("%s x%d" % [_get_item_name(loot_item), material_amount])
    else:
        LootManager.store_loot(loot_item, material_amount)
        summary_parts.append("%s x%d (Peti Loot)" % [_get_item_name(loot_item), material_amount])
    if randf() < seed_drop_chance:
        if InventoryManager.add_item("seed_basic", 1):
            summary_parts.append("Bibit Basic x1")
        else:
            LootManager.store_loot("seed_basic", 1)
            summary_parts.append("Bibit Basic x1 (Peti Loot)")
    QuestManager.record_event("monster_kill", monster_id, 1)
    defeated.emit(monster_id, monster_name, " + ".join(summary_parts), _home_position, scene_file_path)
    queue_free()

func _get_item_name(item_id: String) -> String:
    # InventoryManager sudah memuat dan memvalidasi katalog item saat game dimulai.
    # Gunakan sumber data yang sama agar tidak memanggil get_as_text() pada Resource JSON.
    if is_instance_valid(InventoryManager):
        return InventoryManager.get_item_name(item_id)
    return item_id
