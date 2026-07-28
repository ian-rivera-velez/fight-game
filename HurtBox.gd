class_name HurtBox
extends Area2D
@export var own_hitboxes: Array[HitBox]

func _init() -> void:
	collision_layer = 0
	collision_mask = 2

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(hitbox: HitBox) -> void:
	if (hitbox == null) or (hitbox in own_hitboxes):
		return
	
	if owner.has_method("take_damage"):
		var knockback_dir = sign(owner.global_position.x - hitbox.owner.global_position.x)
		owner.take_damage(hitbox.damage, hitbox.type, knockback_dir)
