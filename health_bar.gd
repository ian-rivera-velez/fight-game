extends TextureProgressBar

@export var charToDisplayHealth : AttackingCharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	charToDisplayHealth.health_changed.connect(update);
	update()

func update():
	value = (charToDisplayHealth.health * 100 / charToDisplayHealth.maxHealth)
