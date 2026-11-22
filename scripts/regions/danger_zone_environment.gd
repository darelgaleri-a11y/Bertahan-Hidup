extends Node2D

@onready var main_scene: Node = get_parent()

const RESOURCE_NODE_SCRIPT = preload("res://scripts/resources/resource_gather_node.gd")
const RESOURCE_ATLAS := "res://assets/sprites/resources/resource_nodes_atlas_32px.png"

func _ready() -> void:
    _create_gatherable("charred_wood", "Kayu Hangus", Vector2(220, 315), Rect2(0, 0, 32, 32), 1, 2, 2, 28.0, "axe")
    _create_gatherable("blackstone", "Batu Hitam", Vector2(345, 390), Rect2(32, 0, 32, 32), 1, 2, 3, 25.0, "pickaxe")
    _create_gatherable("ember_crystal", "Kristal Bara", Vector2(365, 145), Rect2(160, 0, 32, 32), 1, 2, 2, 35.0, "pickaxe")
    _create_gatherable("ancient_shard", "Pecahan Kuno", Vector2(500, 420), Rect2(128, 0, 32, 32), 1, 1, 1, 45.0, "pickaxe")
    RegionManager.region_changed.connect(_on_region_changed)
    _sync_region(RegionManager.current_region_id)

func _create_gatherable(item_id: String, title: String, at: Vector2, rect: Rect2, low: int, high: int, charges: int, respawn: float, tool: String) -> void:
    var node := Node2D.new()
    node.name = "Gather_" + item_id
    node.position = at
    node.set_script(RESOURCE_NODE_SCRIPT)
    node.call("configure", item_id, title, RESOURCE_ATLAS, rect, low, high, charges, respawn, tool)
    add_child(node)

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
