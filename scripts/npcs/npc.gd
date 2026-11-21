extends Node2D

@export var npc_id: String = "villager"
@export var display_name: String = "Penduduk"
@export_multiline var greeting: String = "Halo!"
@export var interaction_hint: String = "Tekan E untuk berbicara"
@export var region_id: String = "village"

func _ready() -> void:
    add_to_group("npc_entities")
    if npc_id.strip_edges().is_empty():
        push_warning("NPC tanpa npc_id: " + name)
    if not RegionManager.region_changed.is_connected(_on_region_changed):
        RegionManager.region_changed.connect(_on_region_changed)
    _sync_region_visibility()

func _on_region_changed(_new_region_id: String) -> void:
    _sync_region_visibility()

func _sync_region_visibility() -> void:
    var is_in_current_region := region_id == RegionManager.current_region_id
    visible = is_in_current_region
    if is_in_current_region:
        if not is_in_group("npcs"):
            add_to_group("npcs")
    elif is_in_group("npcs"):
        remove_from_group("npcs")
