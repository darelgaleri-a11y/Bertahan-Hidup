extends Node2D

@onready var main_scene: Node = get_parent()

const RESOURCE_NODE_SCRIPT = preload("res://scripts/resources/resource_gather_node.gd")
const RESOURCE_ATLAS := "res://assets/sprites/resources/resource_nodes_atlas_32px.png"

func _ready() -> void:
    _create_gatherable("iron_ore", "Urat Bijih Besi", Vector2(745, 285), Rect2(128, 0, 32, 32), 1, 2, 3, 24.0, "pickaxe")
    _create_gatherable("blue_crystal", "Kristal Biru Gua", Vector2(690, 145), Rect2(96, 0, 32, 32), 1, 2, 2, 28.0, "pickaxe")
    _create_gatherable("purple_crystal", "Kristal Ungu", Vector2(830, 325), Rect2(160, 0, 32, 32), 1, 2, 2, 32.0, "pickaxe")
    _create_gatherable("cave_mushroom", "Jamur Gua", Vector2(185, 435), Rect2(64, 0, 32, 32), 1, 2, 2, 18.0, "hand")
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
    var in_cave := region_id == "cave"
    visible = in_cave
    var village_ground := main_scene.get_node_or_null("Ground/GroundVisual")
    if village_ground is CanvasItem:
        village_ground.visible = not in_cave and region_id != "forest"
    var pond := main_scene.get_node_or_null("Pond")
    if pond is CanvasItem:
        pond.visible = not in_cave and region_id != "forest"
    for node_name in ["Shopkeeper", "Breeder", "PropertyAgent", "QuestBoard"]:
        var village_node := main_scene.get_node_or_null(node_name)
        if village_node is CanvasItem:
            village_node.visible = not in_cave and region_id != "forest"
