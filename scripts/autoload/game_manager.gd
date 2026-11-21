extends Node

signal money_changed(value: int)
signal farm_value_changed(value: int)
signal notification_requested(message: String)

var money: int = 250
var farm_value: int = 0
var job_level: int = 1

const JOB_THRESHOLDS := [0, 100, 300, 650, 1100, 1800, 2800, 4200, 6000, 8500]

func add_money(amount: int) -> void:
    if amount <= 0:
        return
    money += amount
    money_changed.emit(money)

func spend_money(amount: int) -> bool:
    if amount <= 0 or money < amount:
        return false
    money -= amount
    money_changed.emit(money)
    return true

func add_farm_value(amount: int) -> void:
    if amount <= 0:
        return
    farm_value += amount
    _update_job_level()
    farm_value_changed.emit(farm_value)

func recalculate_progression() -> void:
    var previous_level := job_level
    job_level = 1
    for i in range(JOB_THRESHOLDS.size()):
        if farm_value >= JOB_THRESHOLDS[i]:
            job_level = i + 1
    if job_level > previous_level:
        notification_requested.emit("Job Level naik menjadi %d!" % job_level)

func _update_job_level() -> void:
    recalculate_progression()
