extends AttackingCharacterBody2D

#input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Punch"):
		actionState = ActionState.PUNCHING
	if event.is_action_pressed("Kick"):
		actionState = ActionState.KICKING
	if event.is_action_pressed("Punch Up"):
		actionState = ActionState.PUNCH_UP

func get_move_input() -> int:
	return Input.get_axis("Left", "Right")

func wants_to_jump():
	return Input.is_action_just_pressed("Up")

func wants_to_crouch():
	return Input.is_action_pressed("Down")

func _physics_process(delta: float) -> void:
	super(delta)
	#actually move lol
	move_and_slide()
