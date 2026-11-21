extends Node

signal breeding_completed(result: Dictionary)

const RECIPES := {
    "seed_basic": {
        "output": "seed_advanced",
        "fee": 100,
        "chance": 0.90,
        "label": "Basic → Advanced"
    },
    "seed_advanced": {
        "output": "seed_rare",
        "fee": 250,
        "chance": 0.75,
        "label": "Advanced → Rare"
    },
    "seed_rare": {
        "output": "seed_epic",
        "fee": 500,
        "chance": 0.60,
        "label": "Rare → Epic"
    },
    "seed_epic": {
        "output": "seed_legendary",
        "fee": 1000,
        "chance": 0.40,
        "label": "Epic → Legendary"
    }
}

func get_recipe(seed_id: String) -> Dictionary:
    return RECIPES.get(seed_id, {}).duplicate(true)

func attempt_breeding(seed_id: String) -> Dictionary:
    if not RECIPES.has(seed_id):
        return _result(false, "Resep breeding tidak ditemukan.", false)

    var recipe: Dictionary = RECIPES[seed_id]
    var output_id := str(recipe["output"])
    var fee := int(recipe["fee"])
    var chance := float(recipe["chance"])

    if InventoryManager.get_amount(seed_id) < 2:
        return _result(false, "Dibutuhkan 2 %s." % InventoryManager.get_item_name(seed_id), false)
    if GameManager.money < fee:
        return _result(false, "Money tidak cukup. Biaya: %d." % fee, false)
    if not InventoryManager.item_catalog.has(output_id):
        return _result(false, "Data bibit hasil tidak tersedia.", false)
    if InventoryManager.get_amount(output_id) >= InventoryManager.get_stack_limit(output_id):
        return _result(false, "Stack bibit hasil sudah penuh.", false)

    # Dua bibit sumber dikonsumsi; jika stack habis, slotnya tersedia untuk hasil.
    var projected_slots := InventoryManager.get_used_slots()
    if InventoryManager.get_amount(seed_id) == 2:
        projected_slots -= 1
    if InventoryManager.get_amount(output_id) == 0 and projected_slots >= InventoryManager.SLOT_LIMIT:
        return _result(false, "Inventory penuh. Kosongkan satu slot terlebih dahulu.", false)

    if not GameManager.spend_money(fee):
        return _result(false, "Pembayaran gagal.", false)
    if not InventoryManager.remove_item(seed_id, 2):
        GameManager.add_money(fee)
        return _result(false, "Bibit sumber gagal diambil. Uang dikembalikan.", false)

    var success := randf() < chance
    if success:
        if not InventoryManager.add_item(output_id, 1):
            # Rollback penuh untuk mencegah bibit/uang hilang jika ada kondisi tak terduga.
            InventoryManager.add_item(seed_id, 2)
            GameManager.add_money(fee)
            return _result(false, "Hasil tidak dapat masuk inventory. Transaksi dibatalkan.", false)
        var success_result := {
            "ok": true,
            "success": true,
            "message": "Berhasil! Mendapatkan %s." % InventoryManager.get_item_name(output_id),
            "fee_paid": fee,
            "returned_seed": false
        }
        breeding_completed.emit(success_result)
        return success_result

    # Gagal: satu bibit kembali, satu hilang, dan setengah biaya dikembalikan.
    InventoryManager.add_item(seed_id, 1)
    var refund := int(floor(float(fee) * 0.5))
    GameManager.add_money(refund)
    var failure_result := {
        "ok": true,
        "success": false,
        "message": "Breeding gagal. Satu bibit dikembalikan; refund %d Money." % refund,
        "fee_paid": fee - refund,
        "returned_seed": true
    }
    breeding_completed.emit(failure_result)
    return failure_result

func _result(ok: bool, message: String, success: bool) -> Dictionary:
    return {
        "ok": ok,
        "success": success,
        "message": message,
        "fee_paid": 0,
        "returned_seed": false
    }
