extends CharacterBody2D

signal defeated(loot_summary: String)
signal health_changed(current: int, maximum: int)

@export var max_health: int = 50
@export var attack_damage: int = 5
@export var move_speed: float = 30.0
@export var detection_range: float = 180.0
@export var attack_range: float = 22.0
@export var attack_cooldown: float = 1.2
@export var material_drop_min: int = 1
@export var material_drop_max: int = 2
@export_range(0.0, 1.0) var seed_drop_chance: float = 0.10

var health: int
var player: CharacterBody2D
var _attack_timer: float = 0.0
var _dead: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    add_to_group("monsters")
    health = max_health
    player = get_tree().get_first_node_in_group("player") as CharacterBody2D
    health_changed.emit(health, max_health)

func _physics_process(delta: float) -> void:
    if _dead:
        return
    _attack_timer = maxf(0.0, _attack_timer - delta)
    if not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as CharacterBody2D
        velocity = Vector2.ZERO
        move_and_slide()
        return

    var distance := global_position.distance_to(player.global_position)
    if distance <= detection_range and distance > attack_range:
        velocity = global_position.direction_to(player.global_position) * move_speed
    else:
        velocity = Vector2.ZERO
        if distance <= attack_range and _attack_timer <= 0.0:
            if player.has_method("take_damage"):
                player.take_damage(attack_damage)
            _attack_timer = attack_cooldown
    move_and_slide()

func take_damage(amount: int) -> void:
    if _dead or amount <= 0:
        return
    health = maxi(0, health - amount)
    health_changed.emit(health, max_health)
    if health <= 0:
        _die()

func _die() -> void:
    _dead = true
    velocity = Vector2.ZERO
    var minimum_drop := mini(material_drop_min, material_drop_max)
    var maximum_drop := maxi(material_drop_min, material_drop_max)
    var material_amount := randi_range(maxi(1, minimum_drop), maxi(1, maximum_drop))
    var summary_parts := PackedStringArray()

    if InventoryManager.add_item("slime_gel", material_amount):
        summary_parts.append("Slime Gel x%d" % material_amount)
    else:
        LootManager.store_loot("slime_gel", material_amount)
        summary_parts.append("Slime Gel x%d (Peti Loot)" % material_amount)

    if randf() < seed_drop_chance:
        if InventoryManager.add_item("seed_basic", 1):
            summary_parts.append("Bibit Basic x1")
        else:
            LootManager.store_loot("seed_basic", 1)
            summary_parts.append("Bibit Basic x1 (Peti Loot)")

    var summary := " + ".join(summary_parts)
    QuestManager.record_event("monster_kill", "slime", 1)

    # Sesuai ketetapan progresi game: monster tidak memberi EXP.
    defeated.emit(summary)
    queue_free()
