extends Node2D

@export var npc_id: String = "villager"
@export var display_name: String = "Penduduk"
@export_multiline var greeting: String = "Halo!"
@export var interaction_hint: String = "Tekan E untuk berbicara"

func _ready() -> void:
	add_to_group("npcs")
	if npc_id.strip_edges().is_empty():
		push_warning("NPC tanpa npc_id: " + name)
