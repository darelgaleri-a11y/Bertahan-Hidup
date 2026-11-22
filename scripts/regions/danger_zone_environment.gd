extends Node2D

@onready var main_scene: Node = get_parent()

func _ready() -> void:
    RegionManager.region_changed.connect(_on_region_changed)
    _sync_region(RegionManager.current_region_id)

func _on_region_changed(region_id: String) -> void:
    _sync_region(region_id)

func _sync_region(region_id: String) -> void:
    var in_danger_zone := region_id == "danger_zone"
    visible = in_danger_zone

    var village_ground := main_scene.get_node_or_null("Ground/GroundVisual")
    if village_ground is CanvasItem:
        village_ground.visible = not in_danger_zone and region_id != "forest" and region_id != "cave"

    var pond := main_scene.get_node_or_null("Pond")
    if pond is CanvasItem:
        pond.visible = not in_danger_zone and region_id != "forest" and region_id != "cave"

    for node_name in ["Shopkeeper", "Breeder", "PropertyAgent", "QuestBoard"]:
        var village_node := main_scene.get_node_or_null(node_name)
        if village_node is CanvasItem:
            village_node.visible = not in_danger_zone and region_id != "forest" and region_id != "cave"
