extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal player_defeated

@export var move_speed: float = 110.0
@export var max_health: int = 100
var health: int = 100
var is_defeated: bool = false
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    health = get_effective_max_health()
    health_changed.emit(health, get_effective_max_health())

func _physics_process(_delta: float) -> void:
    if is_defeated:
        velocity = Vector2.ZERO
        move_and_slide()
        return

    var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input_vector * get_effective_move_speed()
    move_and_slide()
    if input_vector.x != 0.0:
        sprite.flip_h = input_vector.x < 0.0

func get_attack_damage() -> int:
    var base_damage := 25 + (StatsManager.get_stat("strength") - 10) + int(EquipmentManager.get_total_stat("attack"))
    return maxi(1, int(round(float(base_damage) * SkillPassiveManager.get_attack_multiplier())))

func get_effective_max_health() -> int:
    return maxi(1, max_health + (StatsManager.get_stat("vitality") - 10) * 5 + int(EquipmentManager.get_total_stat("max_health")) + SkillPassiveManager.get_max_health_bonus())

func get_effective_move_speed() -> float:
    return maxf(40.0, move_speed + float(StatsManager.get_stat("agility") - 5) * 2.0 + EquipmentManager.get_total_stat("move_speed"))

func take_damage(amount: int) -> void:
    if amount <= 0 or health <= 0 or is_defeated:
        return
    var total_defense := StatsManager.get_stat("defense") + int(EquipmentManager.get_total_stat("defense"))
    var reduced_damage := maxi(1, amount - total_defense)
    health = maxi(0, health - reduced_damage)
    health_changed.emit(health, get_effective_max_health())
    if health == 0:
        is_defeated = true
        velocity = Vector2.ZERO
        player_defeated.emit()

func restore_after_defeat(spawn_position: Vector2) -> void:
    health = get_effective_max_health()
    global_position = spawn_position
    velocity = Vector2.ZERO
    is_defeated = false
    health_changed.emit(health, get_effective_max_health())

func heal(amount: int) -> int:
    if amount <= 0 or is_defeated:
        return 0
    var previous_health := health
    health = mini(get_effective_max_health(), health + amount)
    var restored := health - previous_health
    if restored > 0:
        health_changed.emit(health, get_effective_max_health())
    return restored
