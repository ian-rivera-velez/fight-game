extends Area2D
class_name HitBox

@export var damage := 10
@export var type: Global.AttackType

func _init() -> void:
	collision_layer = 2
	collision_mask = 0
