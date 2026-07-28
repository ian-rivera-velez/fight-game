extends CharacterBody2D
class_name AttackingCharacterBody2D

@export var Sprite : AnimatedSprite2D
@export var selfCollision: CollisionShape2D
@export var crouchCollision: CollisionShape2D
@export var punchCollision: CollisionShape2D
@export var punchUpCollision: CollisionShape2D
@export var kickCollision: CollisionShape2D

@onready var hitbox_collisions := {
	"punch": punchCollision,
	"kick": kickCollision,
	"punch_up": punchUpCollision
}

#physics stuff
@export var SPEED := 300.0
@export var JUMP_VELOCITY := -500.0
var direction : Vector2

#State machine :)
enum MoveState {IDLE, WALKING, JUMPING, FALLING, HURT, CROUCH}
var moveState: MoveState = MoveState.IDLE

enum ActionState {NONE, PUNCHING, PUNCH_UP, KICKING}
var actionState: ActionState = ActionState.NONE
#-----------------

#move states
func get_move_input() -> int:
	push_error("wants_to_jump() must be overridden by " + get_script().resource_path)
	return 0
func wants_to_jump() -> bool:
	push_error("wants_to_jump() must be overridden by " + get_script().resource_path)
	return false
func wants_to_crouch() -> bool:
	push_error("wants_to_crouch() must be overridden by " + get_script().resource_path)
	return false

#movement states
func idle_state():
	velocity.x = move_toward(velocity.x, 0, SPEED)
	selfCollision.set_deferred("disabled", false)
	crouchCollision.set_deferred("disabled", true)
	if not is_on_floor():
		moveState = MoveState.FALLING
	if get_move_input():
		moveState = MoveState.WALKING
	if wants_to_jump():
		moveState = MoveState.JUMPING
	if wants_to_crouch():
		moveState = MoveState.CROUCH

func walk_state():
	if is_on_floor():
		if wants_to_jump(): #can jump
			moveState = MoveState.JUMPING
		if direction: #can move side to side
			velocity.x = direction.x * SPEED
		else:
			moveState = MoveState.IDLE
	else: #must fall
		moveState = MoveState.FALLING

func jump_state(): #jumping!
	velocity.y = JUMP_VELOCITY
	moveState = MoveState.FALLING

func fall_state(delta): #falling
	if not is_on_floor():
		selfCollision.set_deferred("disabled", true)
		crouchCollision.set_deferred("disabled", false)
		velocity += get_gravity() * delta
		if direction: #can move side to side
			velocity.x = direction.x * SPEED
	else: #go back to idling when lands
		moveState = MoveState.IDLE

func crouch_state():
	selfCollision.set_deferred("disabled", true)
	crouchCollision.set_deferred("disabled", false)
	if not is_on_floor():
		selfCollision.set_deferred("disabled", false)
		crouchCollision.set_deferred("disabled", true)
		moveState = MoveState.FALLING
	if not wants_to_crouch():
		selfCollision.set_deferred("disabled", false)
		crouchCollision.set_deferred("disabled", true)
		moveState = MoveState.IDLE

func hurt_state(delta):
	print("in hurt state")
	print(velocity.x)
	velocity += get_gravity() * delta
	velocity.x = move_toward(velocity.x, 0, 1000.0*delta)
	
	if abs(velocity.x) < 5:
		moveState = MoveState.IDLE

#action states
func noAction_state():
	for collision in hitbox_collisions.values():
		collision.set_deferred("disabled", true)

func punch_state():
	match actionState:
		ActionState.PUNCHING:
			hitbox_collisions["punch"].set_deferred("disabled", false)
		ActionState.PUNCH_UP:
			hitbox_collisions["punch_up"].set_deferred("disabled", false)

func kick_state():
	hitbox_collisions["kick"].set_deferred("disabled", false)

func take_damage(amount, type, dir):
	print("took damage from: ", type)
	match type:
		Global.AttackType.PUNCH:
			velocity.x = dir * 200
		Global.AttackType.PUNCH_UP:
			velocity.x = dir * 200
			velocity.y = -300
		Global.AttackType.KICK:
			velocity.x = dir * 200
			velocity.y = 200
	moveState = MoveState.HURT
	
	

func _physics_process(delta: float) -> void:
	direction.x = get_move_input()
	#handle state machines
	match moveState:
		MoveState.IDLE:
			idle_state()
		MoveState.WALKING:
			walk_state()
		MoveState.JUMPING:
			jump_state()
		MoveState.FALLING:
			fall_state(delta)
		MoveState.CROUCH:
			crouch_state()
		MoveState.HURT:
			hurt_state(delta)
	match actionState:
		ActionState.NONE:
			noAction_state()
		ActionState.PUNCHING:
			punch_state()
		ActionState.PUNCH_UP:
			punch_state()
		ActionState.KICKING:
			kick_state()
	
	if get_move_input() < 0:
		$PivotPoint.scale.x = -1
	elif get_move_input() > 0:
		$PivotPoint.scale.x = 1
	
	if actionState == ActionState.NONE:
		updateMovementAnimation()
	else:
		updateActionAnimation()



func _on_player_animation_finished(): #reset after actions
	if actionState != ActionState.NONE:
		actionState = ActionState.NONE

func updateMovementAnimation(): #handle moving animations
	match moveState:
		MoveState.IDLE:
			changeAnimation("idle")
		MoveState.WALKING:
			changeAnimation("walk")
		MoveState.JUMPING:
			changeAnimation("jump")
		MoveState.FALLING:
			changeAnimation("jump")
		MoveState.CROUCH:
			changeAnimation("crouch")
		MoveState.HURT:
			changeAnimation("hurt")

func updateActionAnimation(): #handle action animations
	match actionState:
		ActionState.NONE:
			changeAnimation("idle")
		ActionState.PUNCHING:
			changeAnimation("punch")
		ActionState.PUNCH_UP:
			changeAnimation("punch_up")
		ActionState.KICKING:
			changeAnimation("kick")

func changeAnimation(animation): #helper function, dont touch
	if Sprite.animation != animation:
		Sprite.stop()
		Sprite.play(animation)
