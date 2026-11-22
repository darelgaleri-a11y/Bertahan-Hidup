extends Node2D
## Titik pengumpulan resource. Membutuhkan alat yang sesuai untuk pohon dan mineral.

var item_id: String = ""
var display_name: String = "Resource"
var atlas_path: String = ""
var atlas_region: Rect2 = Rect2(0, 0, 32, 32)
var gather_min: int = 1
var gather_max: int = 2
var max_gathers: int = 3
var respawn_seconds: float = 18.0
var interaction_range: float = 58.0
var tool_type: String = "hand"

var _remaining_gathers: int = 0
var _player: Node2D
var _sprite: Sprite2D
var _busy: bool = false

const TOOL_ATLAS := "res://assets/sprites/tools/tool_swing_atlas_32px.png"
const TOOL_REGIONS := {
    "axe": Rect2(0, 0, 32, 32),
    "pickaxe": Rect2(32, 0, 32, 32)
}

func configure(
    p_item_id: String,
    p_display_name: String,
    p_atlas_path: String,
    p_atlas_region: Rect2,
    p_gather_min: int = 1,
    p_gather_max: int = 2,
    p_max_gathers: int = 3,
    p_respawn_seconds: float = 18.0,
    p_tool_type: String = "hand"
) -> void:
    item_id = p_item_id
    display_name = p_display_name
    atlas_path = p_atlas_path
    atlas_region = p_atlas_region
    gather_min = maxi(1, p_gather_min)
    gather_max = maxi(gather_min, p_gather_max)
    max_gathers = maxi(1, p_max_gathers)
    respawn_seconds = maxf(1.0, p_respawn_seconds)
    tool_type = p_tool_type if TOOL_REGIONS.has(p_tool_type) else "hand"

func _ready() -> void:
    _remaining_gathers = max_gathers
    add_to_group("resource_gather_nodes")
    _sprite = Sprite2D.new()
    var texture := load(atlas_path) as Texture2D
    if texture == null:
        push_error("Atlas resource tidak ditemukan: " + atlas_path)
        return
    _sprite.texture = texture
    _sprite.region_enabled = true
    _sprite.region_rect = atlas_region
    _sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    _sprite.position = Vector2(0, -5)
    _sprite.z_index = 2
    add_child(_sprite)

func _process(_delta: float) -> void:
    if _busy or not Input.is_action_just_pressed("interact"):
        return
    if not is_instance_valid(_player):
        _player = get_tree().get_first_node_in_group("player") as Node2D
    if not is_instance_valid(_player):
        return
    if _player.global_position.distance_to(global_position) > interaction_range:
        return
    if _is_nearest_available_node():
        _gather()

func _is_nearest_available_node() -> bool:
    var nearest: Node = null
    var nearest_distance := interaction_range
    for candidate in get_tree().get_nodes_in_group("resource_gather_nodes"):
        if not is_instance_valid(candidate) or not candidate.is_visible_in_tree():
            continue
        if bool(candidate.get("_busy")):
            continue
        var distance := _player.global_position.distance_to(candidate.global_position)
        if distance <= nearest_distance:
            nearest = candidate
            nearest_distance = distance
    return nearest == self

func _gather() -> void:
    if _remaining_gathers <= 0 or not InventoryManager.item_catalog.has(item_id):
        return

    var tool_data: Dictionary = {}
    if tool_type != "hand":
        tool_data = ToolManager.get_best_tool(tool_type)
        if tool_data.is_empty():
            var needed := "Kapak" if tool_type == "axe" else "Beliung"
            GameManager.notification_requested.emit(
                "%s membutuhkan %s. Buat atau miliki alat tersebut terlebih dahulu." % [display_name, needed]
            )
            return

    _play_tool_swing()
    var amount := randi_range(gather_min, gather_max)
    if tool_type != "hand":
        amount += ToolManager.get_gather_bonus(tool_type)

    if not InventoryManager.add_item(item_id, amount):
        LootManager.store_loot(item_id, amount)

    _remaining_gathers -= 1
    var tool_message := ""
    if not tool_data.is_empty():
        tool_message = " dengan %s" % str(tool_data.get("name", "alat"))
    GameManager.notification_requested.emit(
        "%s%s: %s x%d dikumpulkan. Sisa: %d/%d." % [
            display_name,
            tool_message,
            InventoryManager.get_item_name(item_id),
            amount,
            _remaining_gathers,
            max_gathers
        ]
    )
    if _remaining_gathers <= 0:
        _deplete()

func _play_tool_swing() -> void:
    if tool_type == "hand" or not is_instance_valid(_player):
        return
    var texture := load(TOOL_ATLAS) as Texture2D
    if texture == null:
        push_warning("Atlas alat tidak ditemukan: " + TOOL_ATLAS)
        return
    var tool_sprite := Sprite2D.new()
    tool_sprite.texture = texture
    tool_sprite.region_enabled = true
    tool_sprite.region_rect = TOOL_REGIONS[tool_type]
    tool_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    tool_sprite.position = Vector2(13, -10)
    tool_sprite.rotation = -0.9
    tool_sprite.z_index = 20
    _player.add_child(tool_sprite)
    var tween := _player.create_tween()
    tween.set_parallel(true)
    tween.tween_property(tool_sprite, "rotation", 0.85, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_property(tool_sprite, "position", Vector2(20, 2), 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_property(tool_sprite, "modulate:a", 0.0, 0.18).set_delay(0.12)
    tween.finished.connect(tool_sprite.queue_free)

func _deplete() -> void:
    _busy = true
    visible = false
    await get_tree().create_timer(respawn_seconds).timeout
    if not is_inside_tree():
        return
    _remaining_gathers = max_gathers
    visible = true
    _busy = false
    GameManager.notification_requested.emit("%s telah tersedia kembali." % display_name)
