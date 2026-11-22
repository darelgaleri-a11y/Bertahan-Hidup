extends Node

var _layer: CanvasLayer
var _panel: PanelContainer
var _content: VBoxContainer
var _touch_button: Button

func _ready() -> void:
    _create_ui()
    StatsManager.stats_changed.connect(_on_stats_changed)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_V:
        _toggle_panel()
        get_viewport().set_input_as_handled()

func _create_ui() -> void:
    _layer = CanvasLayer.new()
    _layer.name = "CharacterBuildLayer"
    add_child(_layer)

    _touch_button = Button.new()
    _touch_button.name = "BuildTouchButton"
    _touch_button.text = "BUILD"
    _touch_button.position = Vector2(400, 350)
    _touch_button.size = Vector2(96, 52)
    _touch_button.visible = OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()
    _touch_button.pressed.connect(_toggle_panel)
    _layer.add_child(_touch_button)

    _panel = PanelContainer.new()
    _panel.name = "CharacterBuildPanel"
    _panel.position = Vector2(210, 55)
    _panel.size = Vector2(540, 420)
    _panel.custom_minimum_size = Vector2(540, 420)
    _panel.visible = false
    _layer.add_child(_panel)

    var outer := VBoxContainer.new()
    _panel.add_child(outer)
    var header := HBoxContainer.new()
    outer.add_child(header)
    var title := Label.new()
    title.text = "CHARACTER BUILD"
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)
    var close_button := Button.new()
    close_button.text = "TUTUP"
    close_button.pressed.connect(_toggle_panel)
    header.add_child(close_button)

    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    outer.add_child(scroll)
    _content = VBoxContainer.new()
    _content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(_content)
    _refresh_ui()

func _toggle_panel() -> void:
    if not is_instance_valid(_panel):
        return
    _panel.visible = not _panel.visible
    if _panel.visible:
        _refresh_ui()

func _on_stats_changed() -> void:
    if is_instance_valid(_panel) and _panel.visible:
        _refresh_ui()

func _refresh_ui() -> void:
    if not is_instance_valid(_content):
        return
    for child in _content.get_children():
        _content.remove_child(child)
        child.free()

    var points_label := Label.new()
    points_label.text = "Job Level %d  |  Poin tersedia: %d  |  Batas tiap atribut: %d" % [
        GameManager.job_level,
        StatsManager.get_unspent_points(),
        StatsManager.MAX_ALLOCATION_PER_STAT
    ]
    _content.add_child(points_label)

    var info := Label.new()
    info.text = "Dapatkan 2 poin atribut setiap naik Job Level. Pilihan tersimpan permanen pada save game."
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _content.add_child(info)
    _content.add_child(HSeparator.new())

    for stat_name in StatsManager.ALLOCATABLE_STATS:
        var row := HBoxContainer.new()
        _content.add_child(row)
        var details := VBoxContainer.new()
        details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(details)

        var value_label := Label.new()
        value_label.text = "%s: %d  (alokasi +%d)" % [
            StatsManager.get_stat_label(stat_name),
            StatsManager.get_stat(stat_name),
            StatsManager.get_allocated_points(stat_name)
        ]
        details.add_child(value_label)

        var description := Label.new()
        description.text = StatsManager.get_stat_description(stat_name)
        description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        description.modulate = Color(0.82, 0.86, 0.9, 1.0)
        details.add_child(description)

        var add_button := Button.new()
        add_button.text = "+1"
        add_button.custom_minimum_size = Vector2(58, 42)
        add_button.disabled = not StatsManager.can_allocate(stat_name)
        add_button.pressed.connect(_allocate_point.bind(stat_name))
        row.add_child(add_button)

func _allocate_point(stat_name: String) -> void:
    var result: Dictionary = StatsManager.allocate_point(stat_name)
    if is_instance_valid(GameManager):
        GameManager.notification_requested.emit(str(result.get("message", "Alokasi atribut diproses.")))
    _refresh_ui()
