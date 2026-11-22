extends Node
## Memilih alat terbaik yang dimiliki pemain untuk aktivitas gathering.
## Alat disimpan sebagai item inventory sehingga otomatis ikut tersimpan oleh SaveManager.

const TOOL_DEFINITIONS := {
    "axe": ["wooden_axe", "iron_axe"],
    "pickaxe": ["wooden_pickaxe", "iron_pickaxe"]
}

func get_best_tool(tool_type: String) -> Dictionary:
    if not TOOL_DEFINITIONS.has(tool_type):
        return {}
    var best: Dictionary = {}
    for item_id in TOOL_DEFINITIONS[tool_type]:
        if InventoryManager.get_amount(item_id) <= 0:
            continue
        var item_data: Dictionary = InventoryManager.item_catalog.get(item_id, {})
        var power := int(item_data.get("tool_power", 1))
        if best.is_empty() or power > int(best.get("tool_power", 0)):
            best = {
                "item_id": item_id,
                "name": InventoryManager.get_item_name(item_id),
                "tool_type": tool_type,
                "tool_power": power
            }
    return best

func has_tool(tool_type: String) -> bool:
    return not get_best_tool(tool_type).is_empty()

func get_gather_bonus(tool_type: String) -> int:
    var tool := get_best_tool(tool_type)
    if tool.is_empty():
        return 0
    return maxi(0, int(tool.get("tool_power", 1)) - 1)

func get_tool_name(tool_type: String) -> String:
    var tool := get_best_tool(tool_type)
    return str(tool.get("name", "")) if not tool.is_empty() else ""
