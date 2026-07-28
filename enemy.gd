extends AttackingCharacterBody2D

var can_attack := true

#keep track of things
var active_target
var in_personal_space = false

func wants_to_jump() -> bool:
	return getTargetDirection().y == 1

func get_move_input() -> int:
	return getTargetDirection().x

func wants_to_crouch() -> bool:
	return false

#move state functions
func idle_state():
	if active_target and not in_personal_space:
		moveState = MoveState.WALKING
	
	super()

func walk_state():
	if in_personal_space:
		moveState = MoveState.IDLE
		return
	super()

#action state functions
func attack():
	can_attack = false
	
	var attack_type = randf()
	if attack_type > .6:
		actionState = ActionState.PUNCHING
	elif attack_type > .3:
		actionState = ActionState.PUNCH_UP
	else:
		actionState = ActionState.KICKING

func _physics_process(delta: float) -> void:
	super(delta)
	
	if in_personal_space and can_attack:
		attack()
	
	#actually move lol
	move_and_slide()


#helper functions / "behind the scenes"
func getTargetDirection():
	if active_target and not in_personal_space:
		#x position
		if active_target.global_position.x <= global_position.x:
			direction.x = -1
		elif active_target.global_position.x > global_position.x:
			direction.x = 1
		
		#y position
		if active_target.global_position.y < global_position.y - 5:
			direction.y = 1
		else:
			direction.y = 0
	else: direction = Vector2(0, 0)
	
	return direction


#set active target
func _on_detection_area_body_entered(body: Node2D) -> void: 
	if body.is_in_group("player"):
		active_target = body
func _on_detection_area_body_exited(body: Node2D) -> void: 
	if body.is_in_group("player"):
		active_target = null

#set if something in personal space
func _on_personal_space_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		in_personal_space = true
func _on_personal_space_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		in_personal_space = false

func _on_enemy_animation_finished() -> void:
	if not actionState == ActionState.NONE:
		actionState = ActionState.NONE
		
		await get_tree().create_timer(.5).timeout
		can_attack = true
