extends Node

## Bonus pasif dihitung langsung dari level skill yang tersimpan oleh SkillManager.
## Tidak ada data tambahan yang perlu disimpan sehingga save lama tetap kompatibel.

func get_attack_multiplier() -> float:
    var level := SkillManager.get_skill_level("power_strike")
    return 1.0 + float(maxi(0, level - 1)) * 0.03

func get_max_health_bonus() -> int:
    var level := SkillManager.get_skill_level("recovery")
    return maxi(0, level - 1) * 5

func get_stamina_regen_bonus() -> float:
    var level := SkillManager.get_skill_level("recovery")
    return float(maxi(0, level - 1)) * 0.5

func get_build_summary() -> String:
    var power_level := SkillManager.get_skill_level("power_strike")
    var recovery_level := SkillManager.get_skill_level("recovery")
    var attack_bonus := int(round((get_attack_multiplier() - 1.0) * 100.0))
    return "Power Strike Lv.%d: Damage dasar +%d%% | Recovery Lv.%d: HP Maks +%d, Regen Stamina +%.1f/dtk" % [
        power_level,
        attack_bonus,
        recovery_level,
        get_max_health_bonus(),
        get_stamina_regen_bonus()
    ]
