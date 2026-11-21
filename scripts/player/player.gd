extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal player_defeated

@export var move_speed: float = 110.0
@export var max_health: int = 100
var health: int = 100
var is_defeated: bool = false
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    health = max_health
    health_changed.emit(health, max_health)

func _physics_process(_delta: float) -> void:
    if is_defeated:
        velocity = Vector2.ZERO
        move_and_slide()
        return

    var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input_vector * move_speed
    move_and_slide()
    if input_vector.x != 0.0:
        sprite.flip_h = input_vector.x < 0.0

func take_damage(amount: int) -> void:
    if amount <= 0 or health <= 0 or is_defeated:
        return
    health = maxi(0, health - amount)
    health_changed.emit(health, max_health)
    if health == 0:
        is_defeated = true
        velocity = Vector2.ZERO
        player_defeated.emit()

func restore_after_defeat(spawn_position: Vector2) -> void:
    health = max_health
    global_position = spawn_position
    velocity = Vector2.ZERO
    is_defeated = false
    health_changed.emit(health, max_health)
