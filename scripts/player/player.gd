extends CharacterBody2D

@export var move_speed: float = 110.0
@onready var sprite: Sprite2D = $Sprite2D

func _physics_process(_delta: float) -> void:
    var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input_vector * move_speed
    move_and_slide()
    if input_vector.x != 0:
        sprite.flip_h = input_vector.x < 0
